class DockerSlim < Formula
  desc "Minify and secure Docker images"
  homepage "https://dockersl.im"
  url "https://github.com/docker-slim/docker-slim/archive/1.26.1.tar.gz"
  sha256 "f3decf77b6a75cadd194085892469391cf39f7e54bf83d9ed9080308ec2d603a"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "3f2d66638942a745dc8542afd3ef9f5bb41fb0592e60018098cfc552c978ba7d" => :catalina
    sha256 "3f2d66638942a745dc8542afd3ef9f5bb41fb0592e60018098cfc552c978ba7d" => :mojave
    sha256 "3f2d66638942a745dc8542afd3ef9f5bb41fb0592e60018098cfc552c978ba7d" => :high_sierra
    sha256 "d6793e209d696a89e20ca2726db9b7a3d6abbae063d05a854f1b2bfb4b0cb344" => :x86_64_linux
  end

  depends_on "go" => :build

  skip_clean "bin/docker-slim-sensor"

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = "-s -w -X github.com/docker-slim/docker-slim/pkg/version.appVersionTag=#{version}"
    system "go", "build", "-trimpath", "-ldflags=#{ldflags}", "-o", bin/"docker-slim", "./cmd/docker-slim"

    # docker-slim-sensor is a Linux binary that is used within Docker
    # containers rather than directly on the macOS host.
    ENV["GOOS"] = "linux"
    system "go", "build", "-trimpath", "-ldflags=#{ldflags}", "-o", bin/"docker-slim-sensor", "./cmd/docker-slim-sensor"
    (bin/"docker-slim-sensor").chmod 0555
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/docker-slim --version")
    system "test", "-x", bin/"docker-slim-sensor"
  end
end
