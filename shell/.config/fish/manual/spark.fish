# ==============================================================================
# Spark environment (lab-local install)
# ==============================================================================
#
# This snippet exposes a locally unpacked Spark distribution under
# ~/labs/spark/spark-3.5.8-bin-hadoop3 for interactive fish sessions.
#
# It:
# - verifies the Spark installation directory exists before exporting it
# - defines SPARK_HOME as the canonical Spark prefix
# - prepends bin/ to PATH so spark-sql, spark-shell, and spark-submit are found
# - sets SPARK_LOCAL_IP to avoid hostname-to-loopback binding warnings
# - prints a concise status message when the installation is missing or incomplete

set -l spark_home ~/labs/spark/spark-3.5.8-bin-hadoop3

# Only export Spark-related environment variables when the installation
# directory is present. This keeps manual loads safe on machines where
# Spark is not installed yet.
if test -d "$spark_home"
    set -gx SPARK_HOME "$spark_home"

    # Ensure the Spark CLI tools are available in interactive sessions
    # without clobbering the rest of PATH.
    if test -d "$SPARK_HOME/bin"
        fish_add_path -g -p "$SPARK_HOME/bin"
    else
        echo "spark: missing bin directory: $SPARK_HOME/bin"
    end

    # Bind Spark to the local loopback interface to avoid noisy hostname
    # resolution warnings during local development.
    set -gx SPARK_LOCAL_IP 127.0.0.1

    # Confirm that the expected CLI entry point is available after setup.
    if test -x "$SPARK_HOME/bin/spark-sql"
        echo "spark: loaded from $SPARK_HOME"
    else
        echo "spark: spark-sql not found under $SPARK_HOME/bin"
    end
else
    echo "spark: directory not found: $spark_home"
end
