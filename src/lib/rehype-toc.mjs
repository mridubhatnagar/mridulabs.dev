import { visit } from "unist-util-visit";
import GithubSlugger from "github-slugger";

// An author can drop this HTML comment anywhere in a post's markdown to pin
// the TOC to that exact spot. Raw HTML in the markdown hasn't been parsed
// into real hast nodes yet at this point in the pipeline (that's rehype-raw,
// which runs after user rehype plugins), so it still shows up as a "raw"
// node holding the literal string.
const MARKER = "<!-- toc -->";

function headingText(node) {
  let text = "";
  visit(node, "text", (n) => {
    text += n.value;
  });
  return text;
}

// Runs before Astro's own rehypeHeadingIds step, so h2 elements don't have
// an id yet here. Assign one ourselves (rehypeHeadingIds only fills in ids
// that are still missing, so this becomes the final id on the page).
export function rehypeToc() {
  return (tree, file) => {
    if (!file.data.astro?.frontmatter?.toc) return;

    const slugger = new GithubSlugger();
    const headings = [];
    visit(tree, "element", (node) => {
      if (node.tagName !== "h2") return;
      const text = headingText(node);
      node.properties = node.properties || {};
      if (typeof node.properties.id !== "string") {
        node.properties.id = slugger.slug(text);
      }
      headings.push({ id: node.properties.id, text });
    });
    if (headings.length < 2) return;

    const tocNode = {
      type: "element",
      tagName: "nav",
      properties: { className: ["toc"], "aria-label": "Table of contents" },
      children: [
        {
          type: "element",
          tagName: "span",
          properties: { className: ["toc-label"] },
          children: [{ type: "text", value: "Contents" }],
        },
        {
          type: "element",
          tagName: "ul",
          properties: {},
          children: headings.map((h) => ({
            type: "element",
            tagName: "li",
            properties: {},
            children: [
              {
                type: "element",
                tagName: "a",
                properties: { href: `#${h.id}` },
                children: [{ type: "text", value: h.text }],
              },
            ],
          })),
        },
      ],
    };

    // Prefer an explicit <!-- toc --> marker; fall back to right before the
    // first ## heading when a post doesn't have one.
    let inserted = false;
    visit(tree, (node, index, parent) => {
      if (inserted || !parent || typeof index !== "number") return;
      if (node.type === "raw" && node.value.trim() === MARKER) {
        parent.children.splice(index, 1, tocNode);
        inserted = true;
      }
    });

    if (!inserted) {
      visit(tree, "element", (node, index, parent) => {
        if (!inserted && node.tagName === "h2" && parent && typeof index === "number") {
          parent.children.splice(index, 0, tocNode);
          inserted = true;
        }
      });
    }
  };
}
