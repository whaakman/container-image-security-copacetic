FROM busybox AS build-env
RUN touch /empty

FROM scratch
COPY --from=build-env /empty /.emptyfile