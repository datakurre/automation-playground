{ stdenv, fetchurl, jdk, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "zeebe";
  version = "8.1.2";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/camunda/zeebe/releases/download/${version}/camunda-zeebe-${version}.tar.gz";
    sha256 = "7da5f9dfdf16838d8f95e694826e64acea20cc098ffab7e7321c78976b60b102";
  };
  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ jdk ];
  installPhase = ''
    # Cleanup
    rm -f bin/zbctl*

    # Move
    mkdir $out
    mv bin $out
    mv lib $out
#   mv config $out

    # Wrap
    for script in broker gateway restore
    do
      mv $out/bin/$script $out/bin/.$script
#     sed -i "s|sys:app.home}/logs|env:ZEEBE_LOG_PATH}|g" $out/config/log4j2.xml
      makeWrapper $out/bin/.$script $out/bin/$script \
        --prefix PATH : "${jdk}/bin" \
        --set JAVA_HOME "${jdk}/lib/openjdk"
    done
  '';
}
