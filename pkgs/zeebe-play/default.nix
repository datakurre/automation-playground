{ stdenv, fetchurl, jdk, makeWrapper, unzip }:

stdenv.mkDerivation rec {
  pname = "zeebe-play";
  version = "1.2.0-alpha1";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/camunda-community-hub/${pname}/releases/download/${version}/${name}.zip";
    sha256 = "f1bd9ab0ca95c4121450ce2071a542f0c61a82acf514f78d5bc038737287d534";
  };
  nativeBuildInputs = [ unzip ];
  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ jdk ];
  installPhase = ''
mkdir -p $out/usr/share/lib $out/bin
cp nexus-staging/deferred/org/camunda/community/${pname}/${version}/${name}.jar $out/usr/share/lib

cat << EOF >> $out/bin/.zeebe-play
#!/usr/bin/env sh
exec java $JAVA_OPTS -Xms128m -XX:+ExitOnOutOfMemoryError -Dfile.encoding=UTF-8 \
  -jar $out/usr/share/lib/${name}.jar \
  "$@"
EOF
chmod u+x $out/bin/.zeebe-play

makeWrapper $out/bin/.zeebe-play $out/bin/zeebe-play \
--prefix PATH : "${jdk}/bin" \
--set JAVA_HOME "${jdk}/lib/openjdk"
  '';
}
