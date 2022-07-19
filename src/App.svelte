<script lang="ts">
    import { onMount } from "svelte";

    import toml from "toml";

    let status = "click the button!";
    let deps = {};

    const request = async (user: string, repo: string) => {
        let nice = await fetch(
            `https://raw.githubusercontent.com/${user}/${repo}/main/Cargo.toml`
        );
        if (nice.status != 200) {
            nice = await fetch(
                `https://raw.githubusercontent.com/${user}/${repo}/master/Cargo.toml`
            );
        }
        return await nice.text();
    };
    const fetchStuff = async (user: string, repo: string) => {
        // TODO: not hardcode branchname
        request(user, repo).then((data) => {
            if (data == "404: Not Found") {
                status = "not a rust repo!";
                return;
            }

            try {
                let nice = toml.parse(data);
                deps = nice["dependencies"];
            } catch (e) {
                console.log("Coldnt not parse toml: " + e);
                status = "parsing toml failed!";
            }
        });
    };
    onMount(async () => {
        const [tab] = await chrome.tabs.query({
            active: true,
            currentWindow: true,
        });
        // const url = "https://github.com/ChristianChiarulli/colorgen-nvim";
        // const url = "https://github.com/tamton-aquib/veldora";

        // status = tab.url.includes("github.com") ? "Yes" : "No";
        let nice = tab.url.match(/github.com.(.*)\/(.*)/);
        if (nice) {
            let user = nice[1];
            let repo = nice[2];
            fetchStuff(user, repo);
            status = "Rust repo found!";
        } else {
            console.log("Match failed lol!");
            status = "Not a git repo!";
        }
    });
</script>

<main>
    <h2>Status: {status}</h2>

    <table>
        {#each Object.keys(deps) as dep}
            <tr>
                <td class="dep">{dep}</td>
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
    .dep,
    .ver {
        font-size: 2rem;
    }
    .dep {
        color: #986fec;
    }
</style>
