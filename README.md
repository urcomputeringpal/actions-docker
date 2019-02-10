# docker-actions

Opinionated GitHub Actions for common Docker workflows

## Opinions (expressed via default environment variables)

* [`REGISTRY=gcr.io`](https://gcr.io)
* `IMAGE=$GITHUB_REPOSITORY`
  * (Expects a Google Cloud Project named after your GitHub username)
* `TAG=$GITHUB_SHA`
* `DEFAULT_BRANCH_TAG=true`

## Usage

### Google Container Registry Setup

* If you haven't already, [create a Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) named after your GitHub username and follow the [Container Registry Quickstart](https://cloud.google.com/container-registry/docs/quickstart#before-you-begin).
* [Create a Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account) named after your GitHub repository.
* [Add the _Cloud Build Service Account_](https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource) role to this Service Account.
* [Generate a key for this Service Account](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys). Download a JSON key when prompted.
* Create a Secret on your repository named `GCLOUD_SERVICE_ACCOUNT_KEY` (Settings > Secrets) with the contents of:

```shell
echo -n "$(cat path-to/downloaded-key/4a276e9e5862.json)" | base64
```

* That's it! The GitHub Actions in this repository read this Secret and provide the correct values to the Docker daemon by default if present. If a Secret isn't present, `build` _may_ succeed but `push` will return an error!

### Build and push images for each commit

Add the following to `.github/workflow`:

```hcl
workflow { "build and push images for each commit"
  on = "push"
  resolves = "docker push"
}

action "docker build" {
  uses = "urcomputeringpal/docker-actions@master"
  args = "build"
  secrets = ["GCLOUD_SERVICE_ACCOUNT_KEY"]
}

action "docker push" {
  uses = "urcomputeringpal/docker-actions@master"
  needs = "docker build"
  args = "push"
  secrets = ["GCLOUD_SERVICE_ACCOUNT_KEY"]
}
```

## GC stale images

TODO
