use crate::base::Context;

#[allow(dead_code)]
pub fn run_custom(context: &mut Context) {
    context.files.append_json(
        &context
            .system
            .get_home_path("AppData\\Roaming\\Code\\User\\settings.json"),
        r###"
"remote.SSH.remotePlatform": {
    "foo": "linux"
}
"###,
    );
}
