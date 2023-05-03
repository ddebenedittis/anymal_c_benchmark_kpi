# ANYmal C Benchmark KPI

Compute and plot the KPIs obtained from ANYmal C recorded bags during benchmark tests.

## Dependencies

- `MATLAB`
- `ROS Toolbox`
- `Parallel Computing Toolbox` (optional: remove the `parloop`, the `dataqueue`, and the associated functions to eliminate this dependency)

## Usage

### KPI Computation
- Place the bag files (without subfolders) in a folder named `bags` in the parent folder of this repo.
- Run `kpi_computation.m`. Adjust the number of parallel pools to match your RAM capacity. If low on RAM, remove the parallel pools altogether and use a simple for loop.
- Eventually, save the `experiments_data` variable in a `.mat` file to avoid recomputing it.

### KPI Plot
- Run `kpi_plot.m`. This script loads the `kpi_data.mat` file, containing (only) the `experiments_data` variable.
