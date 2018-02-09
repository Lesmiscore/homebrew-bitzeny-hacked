class Bitzenyd < Formula
  desc "Bitzeny daemon"
  homepage "https://bitzeny.info"
  version "2.0.0"
  url "https://github.com/BitzenyCoreDevelopers/bitzeny/releases/download/z2.0.0a/bitzeny-2.0.0.tar.gz"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "berkeley-db@4"
  depends_on "boost"
  depends_on "libevent"
  depends_on "miniupnpc"
  depends_on "openssl"
  depends_on "protobuf"
  depends_on "bsdmainutils" => :build unless OS.mac? # `hexdump` from bsdmainutils required to compile tests
  depends_on "zeromq"
  needs :cxx11

  patch do
    url "https://gist.github.com/nao20010128nao/84543385ae23e956c38e5d8f1963906e/raw/17e8c74d4e826ad4ffd6276c1ce07791e35a11cb/patchme.diff"
    sha256 "559ad6d4bf5f00882074fdd7de08268073d6ebcb350c3ae82256eeeaac2e5d1b"
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j4 -l2.5" if ENV["CIRCLECI"]
    if MacOS.version == :el_capitan && MacOS::Xcode.installed? &&
      MacOS::Xcode.version >= "8.0"
      ENV.delete("SDKROOT")
    end

    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-tests",
                          "--disable-gui-tests",
                          "--with-gui=no",
                          "--without-libs",
                          "--with-boost-libdir=#{Formula["boost"].opt_lib}",
                          "--prefix=#{prefix}"
    system "make", "install"
    pkgshare.install "share/rpcuser"
  end

  plist_options :manual => "bitzenyd"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/bitzenyd</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    system "false"
  end
end
