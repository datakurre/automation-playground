{ stdenv, fetchurl, jdk, makeWrapper, unzip }:

stdenv.mkDerivation rec {
  pname = "zeebe-simple-monitor";
  version = "2.4.1";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/camunda-community-hub/${pname}/releases/download/${version}/${name}.zip";
    sha256 = "sha256-XRlX++7RBOZUIrfe7x5UB5a4yXcvjDw1R20F51+rxRw=";
  };
  nativeBuildInputs = [ unzip ];
  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ jdk ];
  installPhase = ''
mkdir -p $out/usr/share/lib $out/bin
cp nexus-staging/deferred/io/zeebe/${pname}/${version}/${name}.jar $out/usr/share/lib

cat << EOF >> $out/bin/.zeebe-simple-monitor
#!/usr/bin/env sh
exec java $JAVA_OPTS -Xms128m -XX:+ExitOnOutOfMemoryError -Dfile.encoding=UTF-8 \
  -jar $out/usr/share/lib/${name}.jar \
  "$@"
EOF
chmod u+x $out/bin/.zeebe-simple-monitor

makeWrapper $out/bin/.zeebe-simple-monitor $out/bin/zeebe-simple-monitor \
--prefix PATH : "${jdk}/bin" \
--set JAVA_HOME "${jdk}/lib/openjdk"
  '';
}
