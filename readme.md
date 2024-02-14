# GitHub Action demo leveraging trivy, copa and ACR
This repo contains an example to run trivy and copa inside a GitHub action to scan and patch container images hosted in Azure Container Registry.

## Details
Two specific details need to be pointed out. The action contains a run command to run copa as the default GitHub copa-action does not run well on GitHub runners currently (requires containerd image store). The workaround is to pull the copa binary and run it ourselves. For versioning, some scripting is added, adjust this to your liking and according to your versioning strategy. 

```bash
          wget https://github.com/project-copacetic/copacetic/releases/download/v${COPA_VERSION}/copa_${COPA_VERSION}_linux_amd64.tar.gz
          tar -xzf copa_${COPA_VERSION}_linux_amd64.tar.gz
          chmod +x copa


          # Gets the image name from the matrix provided at beginning of the workflow
          imageName=$(echo ${{ matrix.images }} | cut -d ':' -f1)
          current_tag=$(echo ${{ matrix.images }} | cut -d ':' -f2)
          
          # We are using v1.0.1 in our versioning as an example. The following code will strip this down and adds a patch version ((patch++))
          major=$(echo $current_tag | awk -F. '{print $1}')
          minor=$(echo $current_tag | awk -F. '{print $2}')
          patch=$(echo $current_tag | awk -F. '{print $3}')
          ((patch++))

          patched_tag="$major.$minor.$patch"
          
          # Outputs new tag and current image name for alter use
          echo "patched_tag=$patched_tag" >> $GITHUB_OUTPUT
          echo "imageName=$imageName" >> $GITHUB_OUTPUT

          docker buildx create --use --name builder
          ./copa patch -i ${{ matrix.images }} -r trivy-results.json -t $patched_tag
          echo "copa_patch=true" >> $GITHUB_OUTPUT
```