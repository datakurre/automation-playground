from docutils.parsers.rst.directives.images import Image
from pathlib import Path

import subprocess


class BpmnToImage(Image):

    def run(self):
        bpmn = Path(self.arguments[0])
        self.state.document.settings.record_dependencies.add(str(bpmn))
        png = bpmn.with_suffix(".png")
        subprocess.call(
            [
                "bpmn-to-image",
                f"{bpmn}:{png}",
                "--no-title",
                "--no-footer",
            ]
        )
        subprocess.call(
            [
                "convert",
                png,
                "-transparent",
                "white",
                png,
            ]
        )
        self.arguments[0] = str(png)
        return super().run()


def setup(app):

    app.add_directive("bpmn-to-image", BpmnToImage)

    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
