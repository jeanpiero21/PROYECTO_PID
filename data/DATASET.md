# Dataset: CARPK (Car Parking Lot Dataset)

## Origen
- **Paper:** Hsieh, Lin y Hsu, *Drone-based Object Counting by Spatially Regularized Regional Proposal Network*, ICCV 2017.
- **Página oficial:** https://lafi.github.io/LPN/
- **Copia usada:** Roboflow Universe (https://universe.roboflow.com/cars-0vtjs/carpk-317fw), fork propio, versión 1 (2026-11-08), exportada en formato YOLOv8 **sin preprocesamiento ni aumentaciones** (tamaño original).
- **Licencia:** CC BY 4.0.

## Características generales
| Dato | Valor |
|---|---|
| Imágenes | 1,448 |
| Resolución | 1280 × 720 px (todas) |
| Vista | Cenital (nadir), tomada con dron |
| Clases | `0 = Car`, `1 = Person` |
| Anotación | Bounding box por objeto (formato YOLO) |
| Ubicación local | `data/carpk_raw/CARPK.v1i.yolov8/` (no versionado en git) |

El split train/valid/test de Roboflow (1014/289/145) **no importa** para este proyecto, porque no se entrena ningún modelo.

## Formato de las anotaciones (YOLOv8)
Cada imagen `X.jpg` tiene un archivo `X.txt` en `labels/`. Cada línea es un objeto:
```
clase  x_centro  y_centro  ancho  alto      (normalizados de 0 a 1)
```
Para pasar a píxeles: `x_px = x * 1280`, `y_px = y * 720`.
**Ground truth del conteo = número de líneas con clase 0 (Car).** La clase 1 (Person) se ignora.

## Vuelos (el prefijo del nombre del archivo indica fecha y lugar)
Ejemplo: `20161030_GF2_00017_png.rf.<hash>.jpg` → vuelo `20161030_GF2`, frame 17.

| Vuelo | Imágenes | Autos por imagen (mín / mediana / máx) | Personas anotadas | Tamaño típico de auto (px) | GSD estimado* | Observaciones |
|---|---|---|---|---|---|---|
| `20160331_NTU` | 81 | 1 / 37 / 59 | 45 | 107 × 50 | ~4.2 cm/px | Imagen muy clara (sobreexpuesta), **muchas motos sin anotar** (posibles falsos positivos), cajones visibles |
| `20161029_NTU` | 162 | 11 / 43 / 70 | 149 | 110 × 53 | ~4.1 cm/px | Nublado, **asfalto mojado con manchas oscuras** (pueden confundirse con autos negros) |
| `20160524_GF1` | 189 | 21 / 36 / 42 | 741 | 78 × 43 | ~5.8 cm/px | Soleado, **sombras fuertes y árboles** que tapan autos, techo amarillo, bermas verdes |
| `20160524_GF2` | 193 | 25 / 59 / 87 | 968 | 78 × 37 | ~5.8 cm/px | Mismo lugar que GF1, mismo día |
| `20161030_GF1` | 209 | 18 / 40 / 68 | 712 | 95 × 48 | ~4.7 cm/px | Nublado, mismo lugar que GF1 otro día |
| `20161030_GF2` | 155 | 18 / 37 / 73 | 571 | 117 × 55 | ~3.8 cm/px | **Nublado (pocas sombras), filas largas de cajones con líneas blancas claras, ocupación variada** |
| `20161225_TPZ` | 459 | 2 / 112 / 188 | 1,180 | 76 × 36 | ~5.9 cm/px | Muy denso, filas en diagonal, sol con sombras, autos pegados. **Caso difícil** |

\* GSD estimado = 450 cm (largo típico de un auto) / largo mediano del auto en píxeles.

Miniaturas de cada vuelo con las anotaciones dibujadas (amarillo = Car, magenta = Person): `docs/figuras/dataset/`.

## Organización local por vuelo
Las 1,448 imágenes (train + valid + test juntas) también están copiadas y separadas por vuelo, con nombres cortos ordenados por frame:
```
data/carpk_raw/
├── CARPK.v1i.yolov8/          # export original de Roboflow (intacto)
├── vuelo_20160331_NTU/        # 81  imágenes  → NTU_00001.jpg ... + labels/NTU_00001.txt ...
├── vuelo_20161029_NTU/        # 162
├── vuelo_20160524_GF1/        # 189 → GF1_00001.jpg ...
├── vuelo_20160524_GF2/        # 193
├── vuelo_20161030_GF1/        # 209
├── vuelo_20161030_GF2/        # 155 → GF2_00001.jpg ...
└── vuelo_20161225_TPZ/        # 459 → TPZ_00001.jpg ...
```
Cada carpeta tiene `images/` y `labels/`. El número del nombre es el frame del video del dron.

## Proporción de cada vuelo en el total (train + valid + test)
| Vuelo | Train | Valid | Test | Total | % del dataset |
|---|---|---|---|---|---|
| `20160331_NTU` | 55 | 18 | 8 | 81 | 5.6 % |
| `20161029_NTU` | 112 | 30 | 20 | 162 | 11.2 % |
| `20160524_GF1` | 132 | 40 | 17 | 189 | 13.1 % |
| `20160524_GF2` | 127 | 41 | 25 | 193 | 13.3 % |
| `20161030_GF1` | 145 | 43 | 21 | 209 | 14.4 % |
| `20161030_GF2` | 105 | 36 | 14 | 155 | 10.7 % |
| `20161225_TPZ` | 338 | 81 | 40 | 459 | 31.7 % |
| **Total** | **1014** | **289** | **145** | **1448** | **100 %** |

Agrupado por estacionamiento (los 4 del paper): NTU 243 (16.8 %), GF1 398 (27.5 %), GF2 348 (24.0 %), TPZ 459 (31.7 %).

## Selección final para el proyecto
Copiadas a `data/originales/` (imágenes) y `data/anotaciones/` (labels YOLO). Detalle en `data/anotaciones/seleccion.csv`.
Criterio: imágenes de `20161030_GF2` ordenadas por número de autos, eligiendo valores cercanos a 18, 23, 30, 36, 44, 56, 64 y 73, con al menos 12 frames de separación para evitar tomas casi idénticas.

| Nombre | Frame original | Autos reales | Rol | Observación |
|---|---|---|---|---|
| `gf2_01` | GF2_00006 | 18 | Calibración | Ocupación baja; techo con franjas (caso difícil) |
| `gf2_02` | GF2_00089 | 23 | Calibración | Incluye un vehículo grande (van/bus) |
| `gf2_03` | GF2_00019 | 30 | Calibración | Manchas de humedad |
| `gf2_04` | GF2_00031 | 36 | Calibración | Dos filas limpias |
| `gf2_05` | GF2_00101 | 44 | Calibración | Ocupación media |
| `gf2_06` | GF2_00129 | 56 | Calibración | Fila con autos en otra orientación |
| `gf2_07` | GF2_00117 | 63 | Calibración | Tres filas, cajones vacíos visibles |
| `gf2_08` | GF2_00149 | 64 | Calibración | Ocupación alta |
| `gen_ntu` | 20161029_NTU / NTU_00073 | 43 | Generalización | Otro estacionamiento, asfalto mojado |
| `gen_tpz` | 20161225_TPZ / TPZ_00098 | 112 | Generalización | Muy denso, otra escala (GSD ~5.9 cm/px) |

Las imágenes de generalización **no se usan para ajustar parámetros**: solo para evaluar el método ya calibrado.

## Retos identificados (para el análisis de resultados)
1. Motos y personas: objetos pequeños que no son autos → filtrar por área con `regionprops`.
2. Manchas de humedad en el asfalto → se parecen a autos oscuros en un umbral simple.
3. Sombras y árboles (GF1 soleado) → autos parcialmente ocultos.
4. Autos pegados (TPZ) → se fusionan en una sola región.
5. Distinta escala entre vuelos (GSD de 3.8 a 5.9 cm/px) → los parámetros dependen del tamaño del auto.
6. Autos cortados en el borde: CARPK **sí los anota**, así que el conteo debe tratarlos de forma consistente.
