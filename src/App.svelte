<script lang="ts">
    import { onMount } from "svelte";
    import toml from "toml";

    let repoType = "click the button!";
    let user: string, repo: string;
    let deps = {};
    const techStack = {
        "Cargo.toml": "Rust",
        "package.json": "JavaScript",
    };

    const request = async () => {
        let baseUrl = `https://raw.githubusercontent.com/${user}/${repo}/`;

        for (const file of Object.keys(techStack)) {
            let sauce = await fetch(baseUrl + "main/" + file);
            if (sauce.status == 200) {
                return [techStack[file], await sauce.text()];
            } else {
                sauce = await fetch(baseUrl + "master/" + file);
                if (sauce.status == 200) {
                    return [techStack[file], await sauce.text()];
                }
            }
        }
        return "404: Not Found";
    };

    const fetchtechStack = async () => {
        // TODO: not hardcode branchname
        request().then((data) => {
            if (data == "404: Not Found") {
                // repoType = "not a rust,js repo!";
                repoType = "nil";
                return;
            }

            try {
                if (data[0] == "Rust") {
                    let nice = toml.parse(data[1]);
                    deps = nice["dependencies"];
                    
                    repoType = "Rust!";
                } else if (data[0] == "JS") {
                    let nice = JSON.parse(data[1]);
                    deps = nice["dependencies"];
                    repoType = "JS!";
                }
            } catch (e) {
                repoType = "parsing toml/json failed!";
            }
        });
    };

    onMount(async () => {
        const [tab] = await chrome.tabs.query({
            active: true,
            currentWindow: true,
        });

        let matches = tab.url.match(/github.com.(.*)\/(.*)/);
        if (matches) {
            user = matches[1];
            repo = matches[2];
            fetchtechStack();
        } else {
            console.log("Match failed!");
            repoType = "Not a git repo!";
        }
    });
</script>

<main>
    <h2>{repoType}</h2>

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
