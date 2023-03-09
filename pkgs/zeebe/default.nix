{ stdenv, fetchurl, jdk, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "zeebe";
  version = "8.1.8";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/camunda/zeebe/releases/download/${version}/camunda-zeebe-${version}.tar.gz";
    sha256 = "sha256-SzVyFaYJVndL12YT5sKpz/NKgoXNoxTT0XIFuPw4B10=";
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
