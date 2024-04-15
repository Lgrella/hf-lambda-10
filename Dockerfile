# Use the cargo-lambda image for building
FROM ghcr.io/cargo-lambda/cargo-lambda:latest as builder

# Create a directory for your application
WORKDIR /usr/src/app

# Copy your source code into the container
COPY . .

# Build the Lambda function using cargo-lambda
RUN cargo lambda build --release --arm64

# Use a new stage for the final image
# copy artifacts to a clean image
FROM public.ecr.aws/lambda/provided:al2-arm64

# Create a directory for your lambda function
WORKDIR /hf2

# Copy the bootstrap binary from the builder stage
COPY --from=builder /usr/src/app/target/ ./ 
# Copy the llama model here 
COPY --from=builder /usr/src/app/src/pythia-1b-q4_0-ggjt.bin ./ 

# Check to make sure files are there 
RUN if [ -d /hf2/lambda/hf2/ ]; then echo "Directory '/hf2' exists"; else echo "Directory '/hf2' does not exist"; fi
RUN if [ -f /hf2/lambda/hf2/bootstrap ]; then echo "File '/hf2/lambda/hf2/bootstrap' exists"; else echo "File '/hf2/lambda/hf2/bootstrap' does not exist"; fi

# Set the entrypoint for the Lambda function
ENTRYPOINT ["/hf2/lambda/hf2/bootstrap"]
