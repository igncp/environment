use crate::base::Context;
use crate::os::append_json_into_vs_code;

#[allow(dead_code)]
pub fn run_custom(context: &mut Context) {
    append_json_into_vs_code(
        context,
        "User\\settings.json",
        r###"
"remote.SSH.remotePlatform": {
    "foo": "linux"
},
"###,
    );
}
