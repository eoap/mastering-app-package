### Goal

Run the `app-water-body-cloud-native.1.0.0.cwl` released application package using `calrissian`, a CWL runner for kubernetes.

`calrissian` creates a pod for each of the Workflow processing step.

### Step 1 - Configure the workspace

The results produced will be available in the local folder `/workspace/runs`

```bash linenums="1" hl_lines="2-4" title="terminal"
--8<--
scripts/setup.sh
--8<--
```

### Step 2 - Download the released Application package

```bash
--8<--
scripts/download-app-water-bodies-cloud-native.sh
--8<--
```

```
sh ${WORKSPACE}/scripts/download-app-water-bodies-cloud-native.sh
```

### Step 3 - Execute the Application Package

```bash
--8<--
scripts/calrissian-cloud-native.sh
--8<--
```

```
sh ${WORKSPACE}/scripts/calrissian-cloud-native.sh
```

New pods are created:

```
(base) jovyan@coder-mrossi:~/mastering-app-package$ kubectl get pods
NAME                       READY   STATUS              RESTARTS   AGE
coder-mrossi               1/1     Running             0          1h
node-crop-2-pod-laqxbhhy   0/1     ContainerCreating   0          8s
node-crop-3-pod-gvdnujzn   0/1     ContainerCreating   0          8s
node-crop-4-pod-qisbfayc   0/1     ContainerCreating   0          8s
node-crop-5-pod-joficzgy   0/1     ContainerCreating   0          8s
node-crop-6-pod-ejarwpxk   0/1     ContainerCreating   0          8s
node-crop-7-pod-ecjgjglq   0/1     ContainerCreating   0          8s
node-crop-pod-ebgkkvpc     0/1     ContainerCreating   0          8s
```

### Step 4 - Inspect the results


```bash
--8<--
scripts/calrissian-inspect-results.sh
--8<--
```

### Expected outcome

```
(base) jovyan@coder-mrossi:~/runs$ tree $( cat /calrissian/results.json | jq -r .stac_catalog.path )
/calrissian/results/tmp3vhr5k8r
├── S2A_10TFK_20210708_0_L2A
│   ├── S2A_10TFK_20210708_0_L2A.json
│   └── otsu.tif
├── S2A_10TFK_20210718_0_L2A
│   ├── S2A_10TFK_20210718_0_L2A.json
│   └── otsu.tif
├── S2A_10TFK_20220504_0_L2A
│   ├── S2A_10TFK_20220504_0_L2A.json
│   └── otsu.tif
├── S2A_10TFK_20220514_0_L2A
│   ├── S2A_10TFK_20220514_0_L2A.json
│   └── otsu.tif
├── S2A_10TFK_20220524_0_L2A
│   ├── S2A_10TFK_20220524_0_L2A.json
│   └── otsu.tif
├── S2B_10TFK_20210713_0_L2A
│   ├── S2B_10TFK_20210713_0_L2A.json
│   └── otsu.tif
└── catalog.json

6 directories, 13 files
```