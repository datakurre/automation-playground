from docutils.parsers.rst.directives.images import Figure
from docutils.parsers.rst.directives.images import Image
from pathlib import Path

import subprocess


class BpmnToImage(Image):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        bpmn = parent / self.arguments[0]
        if bpmn.exists():
            image = bpmn.with_suffix(".svg")
            if not image.exists() or image.stat().st_mtime < bpmn.stat().st_mtime:
                subprocess.call(
                    [
                        "bpmn-to-image",
                        f"{bpmn}:{image}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
            self.state.document.settings.record_dependencies.add(self.arguments[0])
            self.arguments[0] = str(image.relative_to(parent))
        return super().run()


class BpmnToFigure(Figure):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        bpmn = parent / self.arguments[0]
        if bpmn.exists():
            image = bpmn.with_suffix(".svg")
            if not image.exists() or image.stat().st_mtime < bpmn.stat().st_mtime:
                subprocess.call(
                    [
                        "bpmn-to-image",
                        f"{bpmn}:{image}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
            self.state.document.settings.record_dependencies.add(self.arguments[0])
            self.arguments[0] = str(image.relative_to(parent))
        return super().run()


def setup(app):

    app.add_directive("bpmn-to-image", BpmnToImage)
    app.add_directive("bpmn-to-figure", BpmnToFigure)

    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
