{
  pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/bc66bad58ccceccae361e84628702cfc7694efda.tar.gz") {},
  sf ? "0.003"
}:

let

  hadoop = builtins.fetchTarball "http://archive.apache.org/dist/hadoop/core/hadoop-3.2.1/hadoop-3.2.1.tar.gz";

in
with pkgs; stdenv.mkDerivation rec {
  name = "ldbc_snb_datagen_hadoop_${sf}";

  src = ./.;

  buildInputs = [ maven openjdk8 python2 ];

  buildPhase = ''
    mkdir $out

    cp params-csv-basic.ini params.ini

    cat > params.ini <<EOF
    ldbc.snb.datagen.generator.scaleFactor:snb.interactive.${sf}

    ldbc.snb.datagen.serializer.numUpdatePartitions:16
    ldbc.snb.datagen.serializer.dynamicActivitySerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.activity.CsvBasicDynamicActivitySerializer
    ldbc.snb.datagen.serializer.dynamicPersonSerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.person.CsvBasicDynamicPersonSerializer
    ldbc.snb.datagen.serializer.staticSerializer:ldbc.snb.datagen.serializer.snb.csv.staticserializer.CsvBasicStaticSerializer
    EOF

    export HADOOP_CLIENT_OPTS="-Xmx2G"
    export HADOOP_HOME=${hadoop}
    ./run.sh

    cp -r social_network $out/
    cp -r substitution_parameters $out/
  '';

  dontInstall = true;
  __noChroot = true;
}
