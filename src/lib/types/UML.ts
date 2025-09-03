import * as joint from "@joint/core";

export interface IUMLClass extends joint.dia.Element {
    updateLayout: () => void;
    // Note: this is only for autocomplete, jointjs handles them internally
    get(key: 'name'): string;
    get(key: 'attributesList'): string[];
    get(key: 'operationsList'): string[];
}

export interface IUMLLink extends joint.dia.Link {
    // Aggiungiamo i metodi personalizzati se ne avessimo
    updateLabels: () => void;

    // Aggiungiamo le proprietà personalizzate con i loro tipi
    get(key: 'sourceMultiplicity'): string;
    get(key: 'name'): string;
    get(key: 'targetMultiplicity'): string;
}