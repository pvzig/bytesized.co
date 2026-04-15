FROM swift:6.2.4-bookworm AS build

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Package.swift Package.resolved ./
COPY Sources ./Sources
COPY Tests ./Tests

RUN swift build -c release --product Server

FROM swift:6.2.4-bookworm-slim AS runtime

WORKDIR /app

COPY --from=build /app/.build/release/Server /usr/local/bin/Server

ENV HOST=0.0.0.0
ENV PORT=8080

EXPOSE 8080

CMD ["Server"]
