# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "Open Automation Playground"
author = "Asko Soukka"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

import sys, os

sys.path.append(os.path.abspath("exts"))
extensions = [
    "myst_parser",
    "sphinx_copybutton",
    "bpmn_to_image",
    "dmn_to_html",
    "form_to_image",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]
myst_heading_anchors = 3

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinx_rtd_theme"
html_show_copyright = False
html_show_sourcelink = False
html_show_sphinx = False
html_theme_options = dict(display_version=False, logo_only=True)
html_static_path = ["_static"]
html_css_files = [
    "diagram-js.css",
    "bpmn-js.css",
    "bpmn-embedded.css",
    "bpmn-js-token-simulation.css",
    "custom.css",
    "dmn-js-shared.css",
    "dmn-js-decision-table.css",
    "dmn-js-literal-expression.css",
    "dmn.css",
    "form-js.css",
]
html_js_files = [
    "minipres.js",
    "bpmn-js-token-simulation.js",
    "form-viewer.umd.js",
    "custom.js"
]

# FEEL lexer

from feel import FeelLexer
from pygments.lexers import get_lexer_by_name


def setup(app):
    app.add_lexer("feel", FeelLexer())
