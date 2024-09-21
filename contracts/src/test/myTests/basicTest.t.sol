import "forge-std/Test.sol";
import {ICollateralRegistry} from "../../Interfaces/ICollateralRegistry.sol";

contract BasicTest is Test {
    ICollateralRegistry collateralRegistry;
    function setUp() public {
        // Load the manifest.json file
        string memory manifest = vm.readFile("deployment-manifest.json");

        // Parse the contract address
        collateralRegistry = ICollateralRegistry(vm.parseJsonAddress(manifest, ".collateralRegistry"));
        // try vm.envAddress("COLLATERAL_REGISTRY") returns (address value) {
        //     collateralRegistry = ICollateralRegistry(value);
        // } catch {
            
        // }

        // Create an instance of the contract at the deployed address
        vm.label(address(collateralRegistry), "CollateralRegistry");
    }

    //test to make sure collateratResgistry is not null
    function testCollateralRegistry() public {
        assertEq(address(collateralRegistry) != address(0), true);

    }
    //test baseRate differnet than 0
    function testBaseRate() public {
        uint256 baseRate = collateralRegistry.baseRate();
        assertEq(baseRate != 0, true);
    }
    //test to make sure boldToken() is not null
    function testBoldToken1() public {
        address boldToken = address(collateralRegistry.boldToken());
        assertEq(boldToken != address(0), true);
    }

    function testBoldToken2() public {
        address expected = 0x8B01623F94517F1067F1d547c784e43fA408a1F1;
        address actual = address(collateralRegistry.boldToken());
        assertEq(actual, expected);
    }

}