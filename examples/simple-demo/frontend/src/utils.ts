export async function resolvePageComponent(name: string) {
  try {
    const module = await import(`./Pages/${name}.tsx`);
    return module.default;
  } catch (error) {
    throw new Error(`Page ${name} not found`);
  }
}
