import Grimpan from "./grimpan.js";
console.log(Grimpan.getInstacne() === Grimpan.getInstacne());
function main(instance) {
    instance.initialize();
}
main(Grimpan.getInstacne());
// main(toEditorSettings.getInstacne());
