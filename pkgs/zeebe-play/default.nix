{ stdenv, fetchurl, jdk, makeWrapper, unzip }:

let
  robotTask = fetchurl {
    url = "https://raw.githubusercontent.com/datakurre/camunda-modeler-robot-plugin/7a70112bb9cd72713823003bb13101f44a7bc67c/dist/module-iife.js";
    sha256 = "cb26937b3b9f2382647e5ce964e4fd8abf274d59f04164aba12a80ad81c726ae";
  };

in

stdenv.mkDerivation rec {
  pname = "zeebe-play";
  version = "1.6.1";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/camunda-community-hub/${pname}/releases/download/${version}/${name}.zip";
    sha256 = "d3334434429de055d2c193bd3230788f5db54e7d2cc20598c33cb0cf2324f8e1";
  };
  nativeBuildInputs = [ unzip ];
  buildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ jdk ];
  installPhase = ''
mkdir -p $out/usr/share/lib $out/bin
cp nexus-staging/staging/*/org/camunda/community/${pname}/${version}/${name}.jar $out/usr/share/lib

jar xf nexus-staging/staging/*/org/camunda/community/${pname}/${version}/${name}.jar BOOT-INF/classes/templates/fragments/footer.html
jar xf nexus-staging/staging/*/org/camunda/community/${pname}/${version}/${name}.jar BOOT-INF/classes/public/js/view-bpmn.js

substituteInPlace BOOT-INF/classes/templates/fragments/footer.html \
    --replace \
    '<script src="/js/view-bpmn.js"' \
    '<script src="/js/robot-task.js""text/javascript"></script><script src="/js/view-bpmn.js"'
substituteInPlace BOOT-INF/classes/public/js/view-bpmn.js \
    --replace \
    "height: '100%'" "height: '100%', additionalModules: [ RobotTaskModule ]"
cp ${robotTask} BOOT-INF/classes/public/js/robot-task.js

jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/templates/fragments/footer.html
jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/public/js/robot-task.js
jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/public/js/view-bpmn.js

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
