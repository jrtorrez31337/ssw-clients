import { Canvas } from '@react-three/fiber';
import { OrbitControls, Stars } from '@react-three/drei';
import { type ShipType } from '../api/ships';
import './ShipPreview.css';

interface ShipModel3DProps {
  shipType: ShipType;
}

function ShipModel3D({ shipType }: ShipModel3DProps) {
  // For alpha, use basic geometries
  // Later, load GLTF models: const { scene } = useGLTF('/models/scout.glb');

  const getShipGeometry = () => {
    switch (shipType) {
      case 'scout':
        // Scout: Fast and sleek
        return <dodecahedronGeometry args={[1, 0]} />;
      case 'fighter':
        // Fighter: Angular and aggressive
        return <octahedronGeometry args={[1, 0]} />;
      case 'trader':
        // Trader: Bulky cargo vessel
        return <boxGeometry args={[1.5, 0.8, 2]} />;
      case 'explorer':
        // Explorer: Pointed long-range vessel
        return <coneGeometry args={[0.8, 2, 8]} />;
      default:
        return <boxGeometry args={[1, 1, 1]} />;
    }
  };

  const getShipColor = () => {
    switch (shipType) {
      case 'scout':
        return '#4a90e2';
      case 'fighter':
        return '#e74c3c';
      case 'trader':
        return '#f39c12';
      case 'explorer':
        return '#2ecc71';
      default:
        return '#4a90e2';
    }
  };

  return (
    <mesh rotation={[0, 0, 0]}>
      {getShipGeometry()}
      <meshStandardMaterial
        color={getShipColor()}
        metalness={0.8}
        roughness={0.2}
        emissive={getShipColor()}
        emissiveIntensity={0.2}
      />
    </mesh>
  );
}

interface ShipPreviewProps {
  shipType: ShipType;
}

export function ShipPreview({ shipType }: ShipPreviewProps) {
  return (
    <div className="ship-preview-container">
      <Canvas camera={{ position: [0, 0, 5], fov: 50 }}>
        <ambientLight intensity={0.3} />
        <directionalLight position={[10, 10, 5]} intensity={1} />
        <pointLight position={[-10, -10, -5]} intensity={0.5} color="#667eea" />
        <Stars
          radius={100}
          depth={50}
          count={3000}
          factor={4}
          saturation={0}
          fade
          speed={1}
        />
        <ShipModel3D shipType={shipType} />
        <OrbitControls
          enableZoom={true}
          enablePan={false}
          minDistance={3}
          maxDistance={10}
          autoRotate
          autoRotateSpeed={2}
        />
      </Canvas>
    </div>
  );
}
