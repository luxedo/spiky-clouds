const sc = require("spiky-clouds");
const inputFile1 = "docs/lena.png";
const inputFile2 = "docs/spiky-clouds.png";
const files = [inputFile1, inputFile2];

for (let i = 0; i < files.length; i++) {
  const filename = files[i];
  sc(filename, filename.replace(".png", "-min-gradient.png"), {
      seed: 42,
      rotation: "min_gradient",
    })
    .then(() => sc(filename, filename.replace(".png", "-max-gradient.png"), {
      seed: 42,
      rotation: "max_gradient",
    }))
    .then(() => sc(filename, filename.replace(".png", "-random.png"), {
      seed: 42,
      rotation: "random",
    }))
    .then(() => sc(filename, filename.replace(".png", "-medium-alpha.png"), {
      seed: 42,
      alpha: 127,
    }))
    .then(() => sc(filename, filename.replace(".png", "-low-alpha.png"), {
      seed: 42,
      alpha: 20,
    }))
    .then(() => sc(filename, filename.replace(".png", "-big-length.png"), {
      seed: 42,
      maxLength: 0.1,
    }))
    .then(() => sc(filename, filename.replace(".png", "-small-length.png"), {
      seed: 42,
      maxLength: 0.01,
    }))
    .then(() => sc(filename, filename.replace(".png", "-big-width.png"), {
      seed: 42,
      maxWidth: 0.05,
      minWidth: 0.001
    }))
    .then(() => sc(filename, filename.replace(".png", "-medium-width.png"), {
      seed: 42,
      maxWidth: 0.01,
    }))
    .then(() => sc(filename, filename.replace(".png", "-angles.png"), {
      seed: 42,
      angles: [45, 135, -45, -135]
    }));
}
