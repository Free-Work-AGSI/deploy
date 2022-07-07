# Free-Work Deploy Tool

## Installation

To deploy, run:
```bash
chmod +x deploy.sh && cp deploy.conf.dist deploy.conf
```

And you have to set in `deploy.conf` file your token and type.

## Deploy

```bash
./deploy {env} {app} {image_tag}
```

- **{env}** must be **prod**, **preprod**, **dev**, **review1**, **review2** or **review3**
- **{app}** must be **front** or **back**
- **{image_tag}** must be the docker image tag of the app (**v1.0.31**, **review-2e5e1d8e**, **dev-4e8e2a71**, ...)
