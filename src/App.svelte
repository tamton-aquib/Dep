<script lang="ts">
    import { onMount } from "svelte";
    import toml from "toml";

    let status = "click the button!";
    let user: string, repo: string;
    let repoType: string;
    let deps = {};
    const stuff = {
        "Cargo.toml": "Rust",
        "package.json": "JS",
    };

    const request = async () => {
        let baseUrl = `https://raw.githubusercontent.com/${user}/${repo}/`;

        for (const file of Object.keys(stuff)) {
            let sauce = await fetch(baseUrl + "main/" + file);
            if (sauce.status == 200) {
                return [stuff[file], await sauce.text()];
            }

            // if (sauce.status != 200)
            // sauce = await fetch(baseUrl + "master/" + file);
        }
        return "404: Not Found";
    };

    const fetchStuff = async () => {
        // TODO: not hardcode branchname
        request().then((data) => {
            if (data == "404: Not Found") {
                status = "not a rust,js repo!";
                return;
            }

            try {
                if (data[0] == "Rust") {
                    let nice = toml.parse(data[1]);
                    deps = nice["dependencies"];
                    status = "Rust repo found!";
                    repoType = "Rust";
                } else if (data[0] == "JS") {
                    let nice = JSON.parse(data[1]);
                    deps = nice["dependencies"];
                    status = "JS repo found!";
                    repoType = "JS";
                }
                // return "Rust";
            } catch (e) {
                status = "parsing toml failed!";
            }
        });
    };

    onMount(async () => {
        const [tab] = await chrome.tabs.query({
            active: true,
            currentWindow: true,
        });

        // let reponame = "veldora";
        // let reponame = "tamton-aquib.github.io";
        // const tab = { url: `https://github.com/tamton-aquib/${reponame}` };

        let matches = tab.url.match(/github.com.(.*)\/(.*)/);
        if (matches) {
            user = matches[1];
            repo = matches[2];
            fetchStuff();
        } else {
            console.log("Match failed!");
            status = "Not a git repo!";
        }
    });
</script>

<main>
    <h2>Status: {status}</h2>

    <table>
        {#each Object.keys(deps) as dep}
            <tr class="sect">
                <a target="_blank" href="https://crates.io/crates/{dep}"
                    ><td class="dep">{dep}</td></a
                >
                <td class="ver">
                    {#if typeof deps[dep] == "string"}
                        {deps[dep]}
                    {:else}
                        {deps[dep]["version"]}
                    {/if}
                </td>
            </tr>
        {/each}
    </table>
</main>

<style>
    :global(*) {
        background-color: #11121d;
    }
    .dep {
        color: #986fec;
    }
    .dep,
    .ver {
        font-size: 1.3em;
    }
</style>
