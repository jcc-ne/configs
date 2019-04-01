from IPython import get_ipython
from prompt_toolkit.enums import DEFAULT_BUFFER
from prompt_toolkit.filters import HasFocus, ViInsertMode
from prompt_toolkit.key_binding.vi_state import InputMode


ip = get_ipython()


def switch_to_navigation_mode(event):
    vi_state = event.cli.vi_state
    # vi_state.reset(InputMode.NAVIGATION)
    vi_state.input_mode = InputMode.NAVIGATION


try:
    ipapp = ip.pt_cli.application
    registry = ipapp.key_bindings_registry
except AttributeError:
    ipapp = ip.pt_app
    registry = ipapp.key_bindings


registry.add_binding(u'k',u'j',
                     filter=(HasFocus(DEFAULT_BUFFER)
                             & ViInsertMode()))(switch_to_navigation_mode)
