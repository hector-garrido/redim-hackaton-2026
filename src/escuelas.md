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

# Escuelas: Agua y comida

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
const color = d33.scaleSequential(d33.interpolateBlues)
  .domain([0, 1])

const formatPercent = d33.format(".0%")

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

# Agua en Chiapas

Por otra parte, el grupo Cántaro Azul se ha dado a la tarea de visitar escuelas de Chiapas y evaluar la calidad de su agua en los últimos años. Abajo puedes ver su trabajo a lo largo del estado.

El agua evaluada con riesgo bajo se considera potable y segurea, mientras que los casos de agua con riesgo alto muestran mayores índices de color, dureza, y la presencia de bacterias colioformes y E. Coli.

```js
const selected_year_chiapas = view(Inputs.select(
  [
    'Todos',2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025,2026
  ],
  {label: "Año", value: "Todos", width: 2000}
))
```


```js
const data_agua = await FileAttachment("./data/escuelas_agua.csv").csv({typed: true})
const agua_chiapas = data_agua.filter(d => d.estado === 'Chiapas').filter(d => ["alto","medio","bajo"].includes(d.riesgo)).filter(d => selected_year_chiapas === "Todos" || d.año === selected_year_chiapas)
```


```js
const agg_riesgo = d3.rollups(
  agua_chiapas,
  (v) => v.length,
  (d) => d['riesgo']
).map(([riesgo, count]) => ({ riesgo, count }));
```

```js
Plot.plot({
  marginLeft: 150,
  marginBottom: 50,
  marks: [
    Plot.barX(agg_riesgo,
    {
      x: "count",
      y: "riesgo",
      // fill: "#FEC100"
    })
  ],
  x: { label: "Days without locating" },
  y: { label: "Count"}
})
```


```js
const chiapas = await d33.json(
  "https://raw.githubusercontent.com/PhantomInsights/mexico-geojson/refs/heads/main/2023/states/Chiapas.json"
)

const width = 960
const height = 640

const chiapasFeatureCollection = chiapas.type === "FeatureCollection"
  ? chiapas
  : {type: "FeatureCollection", features: [chiapas]}

const features = chiapasFeatureCollection.features

const projection = d33.geoMercator()
  .fitSize([width, height], chiapasFeatureCollection)

const path = d33.geoPath().projection(projection)

const riskColor = riesgo => {
  switch ((riesgo || "").toLowerCase()) {
    case "alto":
      return "red"
    case "medio":
      return "yellow"
    case "bajo":
      return "green"
    default:
      return "gray"
  }
}

const points = agua_chiapas
  .map(d => {
    const coords = [+d.longitud, +d.latitud]
    const point = projection(coords)
    return { ...d, x: point[0], y: point[1] }
  })
  .filter(d => Number.isFinite(d.x) && Number.isFinite(d.y))

const tooltipText = d =>
  Object.entries(d)
    .filter(([key]) => key !== "x" && key !== "y")
    .map(([key, value]) => `${key}: ${value}`)
    .join("\n")

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
  .attr("fill", "transparent")
  .attr("stroke", "black")
  .attr("stroke-width", 0.5)

svg.selectAll("circle")
  .data(points)
  .join("circle")
  .attr("cx", d => d.x)
  .attr("cy", d => d.y)
  .attr("r", 5)
  .attr("fill", d => riskColor(d.riesgo))
  .attr("stroke", "black")
  .attr("stroke-width", 0.8)
  .attr("opacity", 0.9)
  .append("title")
  .text(tooltipText)

const chart_chiapas = svg.node()
```
```js
chart_chiapas
```
