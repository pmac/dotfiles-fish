{ fetchurl, imlib2, libwebp, automake, autoconf, libtool }:

imlib2.overrideAttrs (oldAttrs: {
    src = fetchurl {
        url = "https://git.enlightenment.org/legacy/imlib2.git/snapshot/imlib2-1.5.1.tar.gz";
        sha256 = "1gpsd6kxa35gz2x6lc87yy2id25az42vkbcxbnm73cvaqaxvi7p2";
    };

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
      automake autoconf libtool
    ];

    buildInputs = (oldAttrs.buildInputs or []) ++ [
      libwebp
    ];

    preConfigure = ''
      ./autogen.sh
    '';

    patches = (oldAttrs.patches or []) ++ [
      ./webp.patch
    ];
})
