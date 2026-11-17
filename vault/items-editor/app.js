const PENDING_STATE = "en proceso";
const VERSION = 5;

const state = {
  items: [],
  states: [],
  drops: [],
  filter: "todos",
  search: "",
  selected: null,
  original: null,
};

const $ = (id) => document.getElementById(id);
const esc = (s) => String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

function iconUrl(path) {
  if (!path) return "";
  return "/" + path.replace(/^res:\/\//, "");
}

function badgeClass(id) {
  if (id === "listo") return "ok";
  if (id === PENDING_STATE || id === "por revisar") return "pending";
  if (id === "sin empezar") return "off";
  return "mid";
}

function banner(text) {
  const el = $("banner");
  el.textContent = text;
  el.hidden = !text;
}

async function load() {
  const res = await fetch("/api/items").catch(() => null);
  if (!res || !res.ok) {
    banner("No se puede leer el vault. Arranca el servidor: python3 vault/items-editor/server.py y abre http://127.0.0.1:8765");
    return;
  }
  const data = await res.json();
  if (data.version !== VERSION) {
    banner(`El servidor en marcha es antiguo (v${data.version ?? "?"} / página v${VERSION}). Para el proceso y vuelve a lanzar: python3 vault/items-editor/server.py`);
  }
  state.items = data.items;
  state.states = data.states;
  state.drops = data.drops;
  $("state").innerHTML = state.states
    .map((s) => `<option value="${esc(s.id)}">${esc(s.id)} — ${esc(s.meaning)}</option>`)
    .join("");
  renderFilters();
  renderList();
  const params = new URLSearchParams(location.search);
  const initial = params.get("slug");
  if (initial) openItem(initial);
  if (params.has("nuevo")) $("newItem").click();
}

function renderFilters() {
  const counts = {};
  for (const item of state.items) counts[item.state] = (counts[item.state] || 0) + 1;
  const chips = [
    `<button type="button" class="chip ${state.filter === "todos" ? "on" : ""}" data-state="todos">todos <b>${state.items.length}</b></button>`,
  ];
  for (const s of state.states) {
    if (!counts[s.id]) continue;
    chips.push(
      `<button type="button" class="chip ${state.filter === s.id ? "on" : ""}" data-state="${esc(s.id)}" title="${esc(s.meaning)}">${esc(s.id)} <b>${counts[s.id]}</b></button>`
    );
  }
  $("filters").innerHTML = chips.join("");
  for (const b of $("filters").querySelectorAll("button")) {
    b.onclick = () => {
      state.filter = b.dataset.state;
      renderFilters();
      renderList();
    };
  }
}

function visibleItems() {
  const q = state.search.trim().toLowerCase();
  return state.items.filter((item) => {
    if (state.filter !== "todos" && item.state !== state.filter) return false;
    if (!q) return true;
    return [item.name, item.type, item.quality, item.drops, item.slug]
      .join(" ")
      .toLowerCase()
      .includes(q);
  });
}

function renderList() {
  const items = visibleItems();
  $("count").textContent = `${items.length} de ${state.items.length} objetos`;
  $("list").innerHTML = items.length
    ? items
        .map(
          (item) => `
      <button type="button" class="row ${state.selected === item.slug ? "on" : ""}" data-slug="${esc(item.slug)}">
        <span class="thumb"><img src="${esc(iconUrl(item.icon))}" alt="" loading="lazy"></span>
        <span class="row-text">
          <b>${esc(item.name)}</b>
          <small>${esc(item.type || "—")} · ${esc(item.quality || "—")}</small>
        </span>
        <span class="badge ${badgeClass(item.state)}">${esc(item.state || "—")}</span>
      </button>`
        )
        .join("")
    : `<p class="empty">Nada con ese filtro.</p>`;
  for (const row of $("list").querySelectorAll(".row")) {
    row.onclick = () => openItem(row.dataset.slug);
  }
}

async function openItem(slug) {
  const res = await fetch("/api/items/" + encodeURIComponent(slug));
  if (!res.ok) return banner("No se pudo abrir " + slug);
  const item = await res.json();
  state.selected = slug;
  renderList();
  $("empty").hidden = true;
  $("form").hidden = false;
  $("heading").textContent = item.name;
  $("meta").textContent = `${item.type || "—"} · ${item.quality || "—"} · vault/items/${item.slug}.md`;
  $("preview").src = iconUrl(item.icon);
  $("name").value = item.name;
  $("icon").value = item.icon;
  $("state").value = item.state;
  const badge = $("stateBadge");
  badge.textContent = item.state || "—";
  badge.className = "badge " + badgeClass(item.state);
  $("description").value = item.description;
  state.original = snapshot();
  state.originalState = item.state;
  $("readonly").textContent = `Recurso: ${item.resource || "—"} · Drop: ${item.drops || "—"}`;
  $("raw").textContent = item.raw || "";
  renderValues(item.values);
  setStatus("");
  history.replaceState(null, "", "?slug=" + encodeURIComponent(slug));
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function snapshot() {
  return JSON.stringify({
    name: $("name").value,
    icon: $("icon").value,
    description: $("description").value,
    values: collectValues(),
  });
}

function scrollToForm(el) {
  el.hidden = false;
  el.scrollIntoView({ behavior: "smooth", block: "start" });
}

function renderValues(values) {
  $("values").innerHTML = "";
  (values.length ? values : [{ key: "", value: "" }]).forEach(addValueRow);
}

function addValueRow(row = { key: "", value: "" }) {
  const div = document.createElement("div");
  div.className = "value-row";
  div.innerHTML = `
    <input class="v-key" placeholder="campo" value="${esc(row.key)}">
    <input class="v-value" placeholder="valor" value="${esc(row.value)}">
    <button type="button" class="ghost" title="Quitar">✕</button>`;
  div.querySelector("button").onclick = () => div.remove();
  $("values").appendChild(div);
}

function collectValues() {
  return [...$("values").querySelectorAll(".value-row")]
    .map((div) => ({
      key: div.querySelector(".v-key").value.trim(),
      value: div.querySelector(".v-value").value.trim(),
    }))
    .filter((v) => v.key);
}

function setStatus(text, kind = "") {
  const el = $("status");
  el.textContent = text;
  el.className = "status " + kind;
}

$("search").oninput = (e) => {
  state.search = e.target.value;
  renderList();
};

$("addValue").onclick = () => addValueRow();

$("delete").onclick = async () => {
  const name = $("name").value.trim() || state.selected;
  if (!confirm(`¿Borrar «${name}»? Se elimina vault/items/${state.selected}.md y su fila del catálogo. El .tres no se toca.`)) return;
  const res = await fetch("/api/items/" + encodeURIComponent(state.selected), { method: "DELETE" });
  if (!res.ok) return setStatus("No se pudo borrar: " + (await res.text()), "err");
  state.items = state.items.filter((i) => i.slug !== state.selected);
  state.selected = null;
  $("form").hidden = true;
  $("empty").hidden = false;
  renderFilters();
  renderList();
  history.replaceState(null, "", "/");
};

$("newItem").onclick = () => {
  $("form").hidden = true;
  $("empty").hidden = true;
  $("createForm").reset();
  $("newQuality").value = "Normal";
  $("createStatus").textContent = "";
  scrollToForm($("createForm"));
  $("newName").focus();
};

$("createCancel").onclick = () => {
  $("createForm").hidden = true;
  if (state.selected) $("form").hidden = false;
  else $("empty").hidden = false;
};

$("newSlug").oninput = (e) => {
  if (e.target.dataset.touched) return;
  e.target.value = $("newName").value
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
};
$("newSlug").onchange = (e) => (e.target.dataset.touched = "1");

$("createForm").onsubmit = async (event) => {
  event.preventDefault();
  $("createSave").disabled = true;
  try {
    const res = await fetch("/api/items", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        slug: $("newSlug").value,
        name: $("newName").value,
        type: $("newType").value,
        quality: $("newQuality").value,
        icon: $("newIcon").value,
      }),
    });
    if (!res.ok) throw new Error((await res.json()).error || res.statusText);
    const item = await res.json();
    $("createForm").hidden = true;
    await load();
    openItem(item.slug);
    setStatus(`Ficha creada: vault/items/${item.slug}.md (en proceso, falta el .tres).`, "ok");
  } catch (error) {
    $("createStatus").textContent = "Error: " + error.message;
    $("createStatus").className = "status err";
  } finally {
    $("createSave").disabled = false;
  }
};

$("form").onsubmit = async (event) => {
  event.preventDefault();
  $("save").disabled = true;
  try {
    const changed = state.original !== snapshot();
    const chosen = $("state").value;
    const nextState = changed && chosen === state.originalState ? PENDING_STATE : chosen;
    const res = await fetch("/api/items/" + encodeURIComponent(state.selected), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: $("name").value,
        icon: $("icon").value,
        state: nextState,
        description: $("description").value,
        values: collectValues(),
      }),
    });
    if (!res.ok) throw new Error(await res.text());
    const item = await res.json();
    const index = state.items.findIndex((i) => i.slug === item.slug);
    if (index >= 0) state.items[index] = { ...state.items[index], ...item };
    renderFilters();
    renderList();
    $("heading").textContent = item.name;
    $("preview").src = iconUrl(item.icon);
    $("raw").textContent = item.raw || "";
    $("state").value = item.state;
    state.original = snapshot();
    state.originalState = item.state;
    const badge = $("stateBadge");
    badge.textContent = item.state;
    badge.className = "badge " + badgeClass(item.state);
    setStatus(
      item.state === PENDING_STATE
        ? "Guardado en el .md como «en proceso»: todavía NO está en el juego."
        : `Guardado en el .md con estado «${item.state}».`,
      "ok"
    );
  } catch (error) {
    setStatus("Error al guardar: " + error.message, "err");
  } finally {
    $("save").disabled = false;
  }
};

load();
