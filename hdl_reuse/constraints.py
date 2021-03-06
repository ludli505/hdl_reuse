from os.path import basename, join, exists, splitext, dirname


class Constraint:
    """
    Class for handling a constraint file.

    Can handle the regular global constraint files as well as entity-level constraints.
    For the latter to work the constraint file name must be the same as the module file name, which must the same as entity name.
    """

    def __init__(self, file, used_in="all", entity_level_constraint=False):
        self.file = file
        self.used_in = used_in
        self.ref = splitext(basename(file))[0] if entity_level_constraint else None

        self._validate()

    def _validate(self):
        assert self.used_in in ["all", "synth", "impl"], self.used_in
        if self.ref is not None:
            entity_file = join(dirname(self.file), "..", self.ref + ".vhd")
            assert exists(entity_file), "Could not find a matching entity file %s for constraint file %s" % (entity_file, self.file)
