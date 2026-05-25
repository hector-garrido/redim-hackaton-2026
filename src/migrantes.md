```js
const bg = await FileAttachment("./migrantes_background.png").url()
const textColor = "#000000"
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
    color: #000000 !important;
  }
`
// document.documentElement.style.backgroundColor = "transparent"
// document.body.style.backgroundColor = "transparent"
// document.body.style.margin = "0"
// document.body.style.paddingLeft = sidebarOffset
```

# Migración

Gente de todo el mundo ha viajado lejos de sus hogares en busca de mejores oportunidades para su familia o debido a situaciones de emergencia. En este ámbito, México siempre ha sido un país importante, al ser el punto de encuentro entre Estados Unidos y América Latina, y también al tener un historial de políticas que han cambiado a lo largo de los años tanto a favor como en contra de las personas en situación de migración.

## Total

En 2020, el INEGI identificó a cerca de 3 millones de NNAs en situación de migración en el país. Viendo su distribución, destaca que la mayoría se encuentran ubicados en el Estado de México, Jalisco, y Nuevo León, sedes de los 3 espacios urbanos más grandes del país.

```js
const selected_age = view(Inputs.select(
  [
    'Total',
    '12 a 17 años', 
    '5 a 17 años', 
    '5 años', 
    '6 a 11 años'
  ],
  {label: "Edad", value: "Todos", width: 2000}
))

const data_total = FileAttachment("./data/migrantes_total.csv").csv({typed: true})
```


```js
import * as d33 from "npm:d3@5"
import * as topojson from "npm:topojson-client@3"

const mx = await d33.json(
  "https://gist.githubusercontent.com/leenoah1/535b386ec5f5abdb2142258af395c388/raw/a045778d28609abc036f95702d6a44045ae7ca99/geo-data.json"
)

const width = 960
const height = 640

const projection = d33.geoMercator()
  .scale(1800)
  .center([-102, 26])

const path = d33.geoPath().projection(projection)

const features = topojson.feature(mx, mx.objects.MEX_adm1).features

const stateAliases = new Map([
  ["Ciudad de Mexico", "Distrito Federal"],
  ["Ciudad de México", "Distrito Federal"],
  ["CDMX", "Distrito Federal"],
  ["Estado de Mexico", "México"],
  ["Michoacan", "Michoacán"],
  ["Nuevo Leon", "Nuevo León"],
  ["Queretaro ", "Querétaro"],
  ["Queretaro", "Querétaro"],
  ["San Luis Potosi", "San Luis Potosí"],
  ["Yucatan", "Yucatán"],
  ["Coahuila ", "Coahuila"]
])

const normalizeState = s => String(s || "").trim()
const lookupState = s => stateAliases.get(normalizeState(s)) || normalizeState(s)

const valuesByState = new Map()
for (const row of data_total.filter(d => d.variable === selected_age)) {
  const stateName = lookupState(row.state)
  valuesByState.set(stateName, (valuesByState.get(stateName) || 0) + row.value)
}

const values = features.map(d => valuesByState.get(lookupState(d.properties.NAME_1)) ?? 0)
const color = d33.scaleSequential(d33.interpolateYlOrBr)
  .domain([0, 5e5]) // max val in data

const formatPercent = d33.format(",.2r")

const svg = d33.create("svg")
  .attr("viewBox", `0 0 ${width} ${height}`)
  .attr("width", width)
  .attr("height", height)
  .attr("preserveAspectRatio", "xMidYMid meet")
  .style("max-width", "100%")
  .style("display", "block")

svg.selectAll("path")
  .data(features)
  .join("path")
  .attr("d", path)
  .attr("fill", d => color(valuesByState.get(lookupState(d.properties.NAME_1)) ?? 0))
  .attr("stroke", "white")
  .attr("stroke-width", 0.5)

svg.selectAll("text")
  .data(features)
  .join("text")
  .attr("transform", d => `translate(${path.centroid(d)})`)
  .attr("text-anchor", "middle")
  .attr("dominant-baseline", "central")
  .attr("font-size", 15)
  .attr("fill", d => {
    const value = valuesByState.get(lookupState(d.properties.NAME_1))
    return value != null && value > 2e5 ? "white" : "black"
  })
  .attr("stroke", "white")
  .attr("stroke-width", 0.4)
  .attr("paint-order", "stroke")
  .text(d => {
    const value = valuesByState.get(lookupState(d.properties.NAME_1))
    return value == null ? "" : formatPercent(value)
  })

const chart = svg.node()
```
```js
chart
```

## Retos

El Instituto para las Mujeres en la Migración (IMUMI), a partir de solicitudes de información, armó una base de información sobre los NNAs bajo los Planes de Restitución de Derechos emitidos por las Procuradurías de Protección de Niñas, Niños y Adolescentes (PPNNA) a lo largo de distintos estados del país.

```js
const data_retos = (await FileAttachment("./data/migrantes_retos.csv").csv({typed: true}))
  .map(d => ({
    state: d.Entidad,
    value: d.cantidad,
    variable_1: d.Año,
    variable_2: d.edad
  }))

const retos_year = view(Inputs.select(
  Array.from(new Set(data_retos.map(d => d.variable_1))).sort(),
  {label: "Año", value: 2024, width: 2000}
))

const retos_age = view(Inputs.select(
  Array.from(new Set(data_retos.map(d => d.variable_2))).sort(),
  {label: "Edad", value: "total", width: 2000}
))
```

```js
const retosValuesByState = new Map()
for (const row of data_retos.filter(d => d.variable_1 === retos_year && d.variable_2 === retos_age)) {
  const stateName = lookupState(row.state)
  retosValuesByState.set(stateName, (retosValuesByState.get(stateName) || 0) + row.value)
}

const retosMaxValue = d33.max(features, d => retosValuesByState.get(lookupState(d.properties.NAME_1)) ?? 0) || 1
const retosColor = d33.scaleSequential(d33.interpolateBlues)
  .domain([0, retosMaxValue])

const retosSvg = d33.create("svg")
  .attr("viewBox", `0 0 ${width} ${height}`)
  .attr("width", width)
  .attr("height", height)
  .attr("preserveAspectRatio", "xMidYMid meet")
  .style("max-width", "100%")
  .style("display", "block")

retosSvg.selectAll("path")
  .data(features)
  .join("path")
  .attr("d", path)
  .attr("fill", d => retosColor(retosValuesByState.get(lookupState(d.properties.NAME_1)) ?? 0))
  .attr("stroke", "white")
  .attr("stroke-width", 0.5)

retosSvg.selectAll("text")
  .data(features)
  .join("text")
  .attr("transform", d => `translate(${path.centroid(d)})`)
  .attr("text-anchor", "middle")
  .attr("dominant-baseline", "central")
  .attr("font-size", 15)
  .attr("fill", d => {
    const value = retosValuesByState.get(lookupState(d.properties.NAME_1))
    return value != null && value > retosMaxValue * 0.4 ? "white" : "black"
  })
  .attr("stroke", "white")
  .attr("stroke-width", 0.4)
  .attr("paint-order", "stroke")
  .text(d => {
    const value = retosValuesByState.get(lookupState(d.properties.NAME_1))
    return value == null ? "" : formatPercent(value)
  })

const retosChart = retosSvg.node()
```

```js
retosChart
```

## Subsidios

Entre las acciones que ha tomado el gobierno, una de ellas ha sido asignar recursos a los distintos estados y municipios del país para recibir a NNAs migrantes en Centros de Asistencia Social, y no en estaciones migratorias a partir de una reforma de ley en 2020.


```js
const data_subsidios = (await FileAttachment("./data/migrantes_subsidios.csv").csv({typed: true}))
  .map(d => ({
    state: d.estado,
    value: d.subsidio,
    variable: d.año
  }))

const subsidios_year = view(Inputs.select(
  Array.from(new Set(data_subsidios.map(d => d.variable))).sort(),
  {label: "Año", value: 2024, width: 2000}
))
```

```js
const subsidiosValuesByState = new Map()
for (const row of data_subsidios.filter(d => d.variable === subsidios_year)) {
  const stateName = lookupState(row.state)
  subsidiosValuesByState.set(stateName, (subsidiosValuesByState.get(stateName) || 0) + row.value)
}

const subsidiosMaxValue = d33.max(features, d => subsidiosValuesByState.get(lookupState(d.properties.NAME_1)) ?? 0) || 1
const subsidiosColor = d33.scaleSequential(d33.interpolateGreens)
  .domain([0, subsidiosMaxValue])

const subsidiosSvg = d33.create("svg")
  .attr("viewBox", `0 0 ${width} ${height}`)
  .attr("width", width)
  .attr("height", height)
  .attr("preserveAspectRatio", "xMidYMid meet")
  .style("max-width", "100%")
  .style("display", "block")

subsidiosSvg.selectAll("path")
  .data(features)
  .join("path")
  .attr("d", path)
  .attr("fill", d => subsidiosColor(subsidiosValuesByState.get(lookupState(d.properties.NAME_1)) ?? 0))
  .attr("stroke", "white")
  .attr("stroke-width", 0.5)

subsidiosSvg.selectAll("text")
  .data(features)
  .join("text")
  .attr("transform", d => `translate(${path.centroid(d)})`)
  .attr("text-anchor", "middle")
  .attr("dominant-baseline", "central")
  .attr("font-size", 15)
  .attr("fill", d => {
    const value = subsidiosValuesByState.get(lookupState(d.properties.NAME_1))
    return value != null && value > subsidiosMaxValue * 0.55 ? "white" : "black"
  })
  .attr("stroke", "white")
  .attr("stroke-width", 0.4)
  .attr("paint-order", "stroke")
  .text(d => {
    const value = subsidiosValuesByState.get(lookupState(d.properties.NAME_1))
    return value == null ? "" : formatPercent(value)
  })

const subsidiosChart = subsidiosSvg.node()
```

```js
subsidiosChart
```
