---
title: Hola, Observable
---

# Hola, Observable

Estoy escribiendo mi primera página del framework y quiero sentir la reactividad
desde el minuto uno.

```js
const repeticiones = view(Inputs.range([1, 20], {step: 1, value: 3, label: "¿Cuántas veces?"}));
```

```js
display(html`<p>${"Observable ".repeat(repeticiones)}</p>`);
```

```js
const fuentes = FileAttachment("./data/fuentes.csv").csv({typed: true});
```

```js
const umbral = view(Inputs.range([0, 90], {step: 1, value: 30, label: "Umbral mínimo"}));
```

```js
Plot.plot({
  width: 640,
  marginLeft: 140,
  x: {grid: true, label: "Menciones →"},
  y: {label: null},
  marks: [
    Plot.barX(
      fuentes.filter(d => d.menciones >= umbral),
      {y: "recurso", x: "menciones", fill: "#E30A18", sort: {y: "-x"}}
    ),
    Plot.ruleX([umbral], {stroke: "#1D1D1B", strokeDasharray: "3,3"}),
    Plot.ruleX([0])
  ]
})
```
