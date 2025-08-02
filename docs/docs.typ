#import "logic.typ": *

#show figure.where(kind: "constraint").or(figure.where(kind: "operation")): it => {
    set align(left)
    it.body
}

#show heading: set block(above: 1.4em, below: 1em)
#show math.equation: set text(size: 9pt)
#show outline.entry.where(level: 1): set text(weight: "bold")
#show outline.entry.where(level: 1): set outline.entry(fill: none)

// #set text(font: "New Computer Modern", lang: "en", weight: "light", size: 11pt)
#set page(margin: 1.5in)
#set highlight(fill: rgb("fbf1c744"))

#page(align(center + horizon, [
    #heading(numbering: none, outlined: false, text(size: 2em, [Logic Flows]))
    // #text(size: 1.7em, [Ionuţ Cicio]) \
    First Order Logic based domain design
]))


#page(outline())

#set heading(numbering: "1.1")
#set page(numbering: "1")

#pagebreak()

= Introduction

#pagebreak()

#page(width: auto, height: 841.89pt, margin: 20pt)[
    = UML class diagram
    #align(center + horizon, image("formal-UML.svg", height: 770pt))
]

= Data types specification

#logic[Name = String matching ```javascript /^[A-Za-z][A-Za-z\d]*$/```] \
#logic[Multiplicity = (min: Integer $>=$ 0, max: Integer $>=$ 0 [0..1])] \

// TODO: icon for project
// TODO: NameC (ClassName)
// TODO: NameA (AssociationName)
// TODO: Identifier Coloring
// TODO: generalization name (optional)

== Multiplicity

#constraint(
    [C.Multiplicity.min_less_than_max],
    ```
    forall multiplicity, mult_min, mult_max
        (
            Multiplicity(multiplicity) and
            min(multiplicity, mult_min) and
            max(multiplicity, mult_max)
        ) ->
            mult_min <= mult_max
    ```,
)

// #logic[Stringa1: Stringa secondo l'espressione regolare ```javascript /^\S$|^\S.*\S$/```] \
// #logic[Periodo: (inizio: DataOra, fine: DataOra [0..1])] \
// #logic[CodiceNazioneISO: Stringa secondo standard #text(class-color)[ISO 3166-1 alpha-2]] \
//
// #text(comment-color)[\/\/ Non ho voglia di gestire a.C. e d.C.] \
// #logic[Anno: Tipo soggetto a #text(class-color)[semantica di mondo reale]]

= Classes specification

== Association

If both roles of an association are connected to the same class, then these roles must have names, and their names must be different.

#constraint(
    [C.Association.same_class_association_mandatory_and_different_role_names],
    ```
    forall association, class, role1, role2
        (
            *association_role*(association, role1) and
            *association_role*(association, role2) and
            *class_role*(class, role1) and
            *class_role*(class, role2)
        ) ->
            exists name1, name2
                name(role1, name1) and
                name(role2, name2) and
                name1 != name2

    ```,
)

== Attribute

Normally the cycle in the diagram could be removed, but identifiers are required to be unique in each class.

#constraint(
    [C.Attribute.identifier_in_class],
    ```
    forall class, attribute, identifier
        (
            *attribute_identifier*(attribute, identifier)
            *class_like_field*(class, attribute)
        ) ->
            *class_identifier*(class, identifier)
    ```,
)

#pagebreak()

== Role

#constraint(
    [C.Role.identifier_in_class],
    ```
    forall class, role, identifier
        (
            *identifier_role*(identifier, identifier)
            *class_role*(class, role)
        ) ->
            *class_identifier*(class, identifier)
    ```,
)

// == StructDefinition
//
// #constraint(
//     [C.StructDefinition.no_recursion],
//     ```
//     ```,
// )
