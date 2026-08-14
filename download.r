library(bayeos)

url <- Sys.getenv("BAYEOS_URL")
user <- Sys.getenv("BAYEOS_USER")
password <- Sys.getenv("BAYEOS_PASSWORD")
bayeos.connect(url, user, password, save_as = "connection")
bayeos.connect("connection")

folder_id <- 135387
from <- "2025-04-01 00:00:00"
until <- "2027-01-01 00:00:00"
output_file <- "scales.csv"

nodes <- bayeos.getChilds(folder_id)

weight_nodes <- nodes[
  nodes$name %in% c("Weight", "Gewicht"),
  c("id", "name", "path")
]

weight_nodes$scale <- basename(sub("/$", "", weight_nodes$path))
weight_nodes$number <- as.integer(sub("^.*[^0-9]([0-9]+)$", "\\1", weight_nodes$scale))
weight_nodes <- weight_nodes[order(weight_nodes$number, weight_nodes$id), ]

if (file.exists(output_file)) {
  file.remove(output_file)
}

for (row_number in seq_len(nrow(weight_nodes))) {
  node <- weight_nodes[row_number, ]
  message("Downloading ", node$scale, " / ", node$name, " (", node$id, ")")

  series <- bayeos.getSeries(
    node$id,
    from = from,
    until = until,
    maxrows = 1e21
  )

  if (NROW(series) == 0) {
    next
  }

  output <- data.frame(
    time = zoo::index(series),
    scale = node$number,
    weight = zoo::coredata(series) < a
  )

  write.table(
    output,
    file = output_file,
    sep = "\t",
    row.names = FALSE,
    col.names = !file.exists(output_file),
    append = file.exists(output_file),
    quote = FALSE
  )
}
