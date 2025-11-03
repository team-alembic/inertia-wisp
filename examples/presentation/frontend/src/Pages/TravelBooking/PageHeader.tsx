export function PageHeader({
  title,
  infoMessage,
}: {
  title: string;
  infoMessage: string;
}) {
  return (
    <div className="bg-white/10 backdrop-blur-md rounded-lg p-6 mb-6">
      <h2 className="text-3xl font-bold text-white mb-2">{title}</h2>
      <p className="text-white/80">{infoMessage}</p>
    </div>
  );
}
