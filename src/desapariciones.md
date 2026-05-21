```js
const bg = await FileAttachment("./desapariciones_background.png").url()
const textColor = "#ffffff"
const id = "page-background-style"
let style = document.head.querySelector(`#${id}`)
if (!style) {
  style = document.createElement("style")
  style.id = id
  document.head.appendChild(style)
}
style.textContent = `
  html, body {
    min-height: 100%;
    background-image: url(${bg});
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-attachment: fixed;
    color: ${textColor};
  }

  .observablehq,
  .observablehq .content,
  .observablehq .main,
  .observablehq > div,
  .observablehq > main,
  .observablehq * {
    // background: transparent !important;
    color: ${textColor} !important;
  }
  /* Ensure form controls (Inputs.select, range, text inputs) use a readable color */
  .observablehq select,
  .observablehq input,
  .observablehq textarea,
  .observablehq .inputs,
  .observablehq .inputs .input,
  .observablehq .inputs select,
  .observablehq .inputs input {
    color: #000000 !important;
    background-color: rgba(255,255,255,0.95) !important;
    border-color: rgba(0,0,0,0.15) !important;
  }

  .observablehq a {
    color: #FEC100 !important;
  }
`
// document.documentElement.style.backgroundColor = "transparent"
// document.body.style.backgroundColor = "transparent"
// document.body.style.margin = "0"
// document.body.style.paddingLeft = sidebarOffset
```

# Desapariciones en Chiapas

Estoy escribiendo mi primera página del framework y quiero sentir la reactividad
desde el minuto uno.

```js
const selected_group = view(Inputs.select(
  ["Todos", "indígena", "mestiza"],
  {label: "Sexo", value: "Todos"}
))


const data = FileAttachment("./data/desapariciones.csv").csv({typed: true})
```

Las chicas adolescentes son un grupo especialmente vulnerable.

```js
const heatData = d3.rollups(
  data.filter(d =>
  selected_group === "Todos" || d.tipo === selected_group
)
  ,
  v => v.length,
  d => d['grupo de edad'],
  d => d['sexo']
).flatMap(([grupoEdad, sexoGroups]) =>
  sexoGroups.map(([sexo, count]) => ({
    grupoEdad,
    sexo,
    count
  }))
);

console.log(heatData);
```

```js
Plot.plot({
  width: 700,
  height: 500,
  marginLeft: 80,
  marginBottom: 70,
  x: { label: "Sexo" },
  y: { label: "Grupo de edad" },
  color: { legend: true, scheme: "ylorrd", label: "Count" },
  marks: [
    Plot.rect(heatData, {
      x: "sexo",
      y: "grupoEdad",
      fill: "count",
      title: d => `${d.grupoEdad} / ${d.sexo}: ${d.count}`
    }),
    Plot.text(heatData, {
      x: "sexo",
      y: "grupoEdad",
      text: d => d.count,
      dy: -6,
      fill: "#000",
      textAnchor: "middle",
      fontSize: 20
    })

  ]
})
```

De los desaparecidos registrados, 7/10 han sido encontrados...

```js
const agg_estatus = d3.rollups(
  data.filter(d =>
  selected_group === "Todos" || d.tipo === selected_group
).filter(d => d['estatus'] != null),
  (v) => v.length,
  (d) => d['estatus']
).map(([estatus, count]) => ({ estatus, count }));
```

```js
Plot.plot({
  marginLeft: 150,
  marginBottom: 50,
  marks: [
    Plot.barX(agg_estatus,
    {
      x: "count",
      y: "estatus",
      fill: "#FEC100"
    })
  ],
  x: { label: "Days without locating" },
  y: { label: "Count"}
})
```

En las desapariciones, los primeros días son críticos. 2 de cada 3 de los localizados aparecieron en los primeros 10 días, mientras que 4 de cada 5 de los localizados aparecieron en los primeros 30 días.

```js
const aux = d3.rollups(
  data.filter(d => d['dias_sin_localizar_cap'] != null),
  (v) => v.length,
  (d) => d['dias_sin_localizar_cap']
).map(([dias_sin_localizar_cap, count]) => ({ dias_sin_localizar_cap, count }));

const maxValue = Math.max(...aux.map(d => d.dias_sin_localizar_cap));

const windowSize = 40;
const scroll = view(Inputs.range([0, maxValue - windowSize], {step: 1, value: 0, label: "Scroll: "}));

const maxY = Math.max(...aux.map(d => d.count));
```


```js
Plot.plot({
  marginLeft: 50,
  marginBottom: 50,
  marks: [
    Plot.barY(aux.filter(d => d.dias_sin_localizar_cap >= scroll && d.dias_sin_localizar_cap < scroll + windowSize),
    {
      x: "dias_sin_localizar_cap",
      y: "count",
      fill: "#FEC100"
    })
  ],
  x: { label: "Days without locating" },
  y: { label: "Count" , domain:[0,maxY]}
})
```

Los NNA indígenas representan casi 2/5 de todos los NNA desaparecidos. Sin embargo, La población indígena representa 1/4 de la población total. Esto quiere decir que los NNA son 50% más vulnerables a desapariciones a comparación del resto de la población.
¿Quieres ver los datos del sitio con información únicamente de NNA indígenas? ¡Puedes hacerlo! Solo ve hasta el inicio de la página, y escoge el grupo en el menú desplegable.