# Dockerfile for running Josh simulations with the fat JAR
# This provides a reproducible environment for simulation execution

FROM quay.io/lib/eclipse-temurin:21-jre

# Set metadata
LABEL maintainer="Josh Simulation Project"
LABEL description="Docker image for running Josh simulations"
LABEL version="1.0"

# Create working directory and set it to code directory
WORKDIR /code

# Copy the code directory contents
COPY code/ /code/
# Copy the fat JAR into the same directory
COPY joshsim-fat.jar /code/joshsim-fat.jar

# Set environment variables for common configuration
ENV JAVA_OPTS="-Xmx4g -Xms2g"

# Default command runs a simulation with configurable parameters
# Can be overridden with docker run command
ENTRYPOINT ["java", "-jar", "joshsim-fat.jar"]

# Default arguments - run with 1 replicate
# Override with: docker run <image> run <your-file.josh> Main --replicates=10
CMD ["run", "invasive_grass_central_utah_local.josh", "Main", "--replicates=1"]
