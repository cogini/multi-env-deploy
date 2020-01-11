from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible import constants as C
from ansible.plugins.callback import CallbackBase
from jinja2.utils import soft_unicode

def fa_map_format(value, pattern):
  return soft_unicode(pattern) % (value)

def fa_exclude_prefix(value, prefix):
  return [x for x in value if not x.startswith(prefix)]

def fa_compact(value):
  return [x for x in value if x]

class FilterModule(object):
  def filters(self):
    return {
      'fa_map_format': fa_map_format,
      'fa_compact': fa_compact,
      'fa_exclude_prefix': fa_exclude_prefix
    }
