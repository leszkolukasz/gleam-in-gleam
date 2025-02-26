antlr="java -jar ./lib/antlr-4.13.2-complete.jar"
grun="java -cp ./lib/antlr-4.13.2-complete.jar org.antlr.v4.gui.TestRig"

antlr GleamLexer.g4
javac -cp ./lib/antlr-4.13.2-complete.jar *.java
grun Gleam tokens -tokens < input.gleam