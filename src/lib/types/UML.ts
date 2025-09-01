import * as joint from "@joint/core";

export interface IUMLClass extends joint.dia.Element {
    // Aggiungiamo i metodi personalizzati
    updateLayout: () => void;
    // Aggiungiamo le proprietà personalizzate (opzionale, ma buona pratica)
    // Nota: JointJS le memorizza internamente, ma è utile per l'autocompletamento.
    get(key: 'name'): string;
    get(key: 'attributesList'): string[];
    get(key: 'operationsList'): string[];
}