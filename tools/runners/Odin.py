from BaseRunner import BaseRunner


class Odin(BaseRunner):
    def __init__(self):
        super().__init__("odin", "odin_II")

        self.url = "https://verilogtorouting.org/"

    def prepare_run_cb(self, tmp_dir, params):

        self.cmd = [self.executable, '--permissive', '-o odin.blif', '-V']

        # odin doesn't seem to support include directories
        # and thus only list of files is provided to it

        if params['top_module'] != '':
            self.cmd.append('--top_module ' + params['top_module'])

        self.cmd += params['files']
