```js
const bg = await FileAttachment("./escuela_background.png").url()
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

# Escuelas:  agua y comida

El grupo Mi Escuela Saludable compiló datos sobre la calidad del entorno alimentario en escuelas de educación básica a partir de encuestas a madres y padres de los estudiantes.

```js
const selected_group = view(Inputs.select(
  ['Aguascalientes', 'Baja California', 'Baja California Sur',
       'Campeche', 'Chiapas', 'Chihuahua', 'Ciudad de Mexico',
       'Coahuila ', 'Colima', 'Durango', 'Estado de Mexico', 'Guanajuato',
       'Guerrero', 'Hidalgo', 'Jalisco', 'Michoacan', 'Morelos',
       'Nayarit', 'Nuevo Leon', 'Oaxaca', 'Puebla', 'Queretaro ',
       'Quintana Roo', 'San Luis Potosi', 'Sinaloa', 'Sonora', 'Tabasco',
       'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatan', 'Zacatecas'],
  {label: "Estado", value: "Ciudad de Mexico"}
))

const data_melt = FileAttachment("./data/escuelas_comida_melt.csv").csv({typed: true})
```


```js
Plot.plot({
  width: 1000,
  marginLeft: 600,
  marginBottom: 50,
  marks: [
    Plot.barX(data_melt.filter(d => d.state === selected_group),
    {
      x: "value",
      y: "variable",
      // fill: "#FEC100"
    })
  ],
  x: { label: "Days without locating", domain: [0, 1], tickFormat: "%" },
  y: { label: "Count"}
})
```












```js
const selected_metric = view(Inputs.select(
  [
    'Afuera de la escuela, ¿hay puestos ambulantes que venden comida chatarra y/o bebidas azucaradas?',
       '¿Se venden refrescos con azúcar (no light)?',
       '¿Se venden otras bebidas envasadas con azúcar como jugos o aguas saborizadas?',
       '¿Se vende comida chatarra de lunes a jueves (por ejemplo, frituras, dulces, galletas, helados)?*',
       '¿Se venden frutas y verduras todos los días (por ejemplo, manzana, zanahoria, naranja, sandía, pepino)?',
       '¿Se venden cereales integrales todos los días (por ejemplo, avena, amaranto, palomitas)?',
       '¿Se venden semillas todos los días (por ejemplo, cacahuates, almendras, habas, chicharos secos)?',
       '¿Hay bebederos o dispensadores de agua funcionando?',
       '¿Hay logos o nombres de marcas de comida chatarra y/o bebidas azucaradas dentro de la escuela (por ejemplo, en la tienda escolar, canchas, patios, eventos y/o torneos)?'     
  ],
  {label: "Métrica", value: "¿Se venden refrescos con azúcar (no light)?", width: 2000}
))
```


```js
import * as d3 from "npm:d3@5"
import * as topojson from "npm:topojson-client@3"

const mx = await d3.json(
  "https://gist.githubusercontent.com/leenoah1/535b386ec5f5abdb2142258af395c388/raw/a045778d28609abc036f95702d6a44045ae7ca99/geo-data.json"
)

const width = 960
const height = 640

const projection = d3.geoMercator()
  .scale(1800)
  .center([-102, 26])

const path = d3.geoPath().projection(projection)

const features = topojson.feature(mx, mx.objects.MEX_adm1).features

const stateAliases = new Map([
  ["Ciudad de Mexico", "Distrito Federal"],
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
for (const row of data_melt.filter(d => d.variable === selected_metric)) {
  const stateName = lookupState(row.state)
  valuesByState.set(stateName, (valuesByState.get(stateName) || 0) + row.value)
}

const values = features.map(d => valuesByState.get(lookupState(d.properties.NAME_1)) ?? 0)
const color = d3.scaleSequential(d3.interpolateBlues)
  .domain([0, 1])

const formatPercent = d3.format(".0%")

const svg = d3.create("svg")
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
    return value != null && value > 0.5 ? "white" : "black"
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