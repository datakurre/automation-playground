{ stdenv, fetchurl, jdk, makeWrapper, unzip }:

let
  robotTask = fetchurl {
    url = "https://raw.githubusercontent.com/datakurre/camunda-modeler-robot-plugin/7a70112bb9cd72713823003bb13101f44a7bc67c/dist/module-iife.js";
    sha256 = "cb26937b3b9f2382647e5ce964e4fd8abf274d59f04164aba12a80ad81c726ae";
  };

  formViewer = fetchurl {
    url = "https://unpkg.com/@bpmn-io/form-js@0.10.1/dist/form-viewer.umd.js";
    sha256 = "2d98d53a2c03e58706d17eb071ee87a296d20c9f3585e32eb58a9da6d215dacd";
  };

in

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

jar xf nexus-staging/deferred/org/camunda/community/${pname}/${version}/${name}.jar BOOT-INF/classes/templates/fragments/footer.html
jar xf nexus-staging/deferred/org/camunda/community/${pname}/${version}/${name}.jar BOOT-INF/classes/public/js/view-bpmn.js

substituteInPlace BOOT-INF/classes/templates/fragments/footer.html \
    --replace \
    '<script src="/js/view-bpmn.js"' \
    '<script src="/js/robot-task.js""text/javascript"></script><script src="/js/view-bpmn.js"'
substituteInPlace BOOT-INF/classes/public/js/view-bpmn.js \
    --replace \
    "height: '100%'" "height: '100%', additionalModules: [ RobotTaskModule ]"
cp ${robotTask} BOOT-INF/classes/public/js/robot-task.js
cp ${formViewer} BOOT-INF/classes/public/js/form-viewer.umd.js

jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/templates/fragments/footer.html
jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/public/js/robot-task.js
jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/public/js/view-bpmn.js
jar uf $out/usr/share/lib/${name}.jar BOOT-INF/classes/public/js/form-viewer.umd.js

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
