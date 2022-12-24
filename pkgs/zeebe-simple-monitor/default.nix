{ stdenv, fetchurl, jdk, makeWrapper, unzip }:

let robotTask = fetchurl {
  url = "https://raw.githubusercontent.com/datakurre/camunda-modeler-robot-plugin/7a70112bb9cd72713823003bb13101f44a7bc67c/dist/module-iife.js";
  sha256 = "cb26937b3b9f2382647e5ce964e4fd8abf274d59f04164aba12a80ad81c726ae";
}; in

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

jar xf nexus-staging/deferred/io/zeebe/${pname}/${version}/${name}.jar BOOT-INF/classes/templates/layout/footer.html
jar xf nexus-staging/deferred/io/zeebe/${pname}/${version}/${name}.jar BOOT-INF/classes/templates/components/bpmn-diagram.html

substituteInPlace BOOT-INF/classes/templates/layout/footer.html \
    --replace \
    '<script src="{{context-path}}js/app.js"' \
    '<script src="{{context-path}}js/robot-task.js"></script><script src="{{context-path}}js/app.js"'
substituteInPlace BOOT-INF/classes/templates/components/bpmn-diagram.html \
    --replace \
    "height: '100%'" "height: '100%', additionalModules: [ RobotTaskModule ]"

mkdir -p BOOT-INF/classes/public/js
cp ${robotTask} BOOT-INF/classes/public/js/robot-task.js

jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/templates/layout/footer.html
jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/templates/components/bpmn-diagram.html
jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/public/js/robot-task.js

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
