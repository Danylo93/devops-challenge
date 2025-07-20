export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-gradient-to-br from-gray-900 to-black text-white p-8">
      <h1 className="text-4xl font-bold mb-4 text-center">
        🚀 DevOps Challenge
      </h1>
      <p className="text-lg text-center max-w-md">
        Esta aplicação foi implantada com sucesso utilizando <strong>Docker</strong>, <strong>AKS</strong>, <strong>Helm</strong> e <strong>Azure DevOps</strong>.
      </p>
    </main>
  );
}
