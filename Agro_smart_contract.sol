// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract AgroContract {
    address public contractOwner;
    uint256 public farmerCount;
    uint256 public produceCount;
    uint256 public shipmentCount;
    enum ProduceStatus {
        Planted,
        Harvested,
        Processed,
        Packed,
        Shipped,
        Received
    }
    struct Farmer {
        uint256 id;
        string name;
        address walletAddress;
        bool isRegistered;
    }
    struct Produce {
        uint256 id;
        string name;
        uint256 quantity;
        uint256 pricePerUint;
        ProduceStatus status;
        address owner;
    }
    struct Shipment {
        uint256 id;
        uint256 productId;
        uint256 quantity;
        string destination;
        bool isShipped;
    }
    mapping(address => Farmer) public farmers;
    mapping(uint256 => address) public farmerIds;

    mapping(uint256 => Produce) public produces;
    mapping(address => uint256[]) public farmerProduceIds;
    mapping(uint256 => Shipment) public shipments;
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Youcannot do this funcitonality");
        _;
    }
    modifier onlyRegisteredFarmer() {
        require(
            farmers[msg.sender].isRegistered,
            "Only the registered farmers can do thisfunctionality"
        );
        _;
    }
    modifier onlyProduceOwner(uint256 _produceId) {
        require(
            produces[_produceId].owner == msg.sender,
            "You can only perform this functtionality if you are the produce owner!"
        );
        _;
    }
    event FarmerRegistered(
        uint256 id,
        string name,
        address indexed walletAddress
    );
    event ProduceAdded(
        uint256 id,
        string name,
        uint256 quantity,
        uint256 pricePerUnit,
        address indexed owner
    );
    event ProduceUpdated(uint256 id, uint256 quantity, uint256 pricePerUnit);
    event ProduceStatusUpdated(uint256 id, ProduceStatus status);
    event ShipmentAdded(
        uint256 id,
        uint256 produceId,
        uint256 quantity,
        string destination,
        bool isShipped
    );

    constructor() {
        contractOwner = msg.sender;
        farmerCount = 0;
        produceCount = 0;
        shipmentCount = 0;
    }

    function registerFarmer(string memory _name) external {
        require(
            !farmers[msg.sender].isRegistered,
            "You have already registered once!"
        );
        farmerCount = farmerCount + 1;

        Farmer memory newFarmer = Farmer(farmerCount, _name, msg.sender, true);
        farmers[msg.sender] = newFarmer;
        farmerIds[farmerCount] = msg.sender;
        emit FarmerRegistered(farmerCount, _name, msg.sender);
    }

    function addProduce(
        string memory _name,
        uint256 _quantity,
        uint256 _pricePerUnit
    ) external onlyRegisteredFarmer {
        produceCount = produceCount + 1;
        Produce memory newproduce = Produce(
            produceCount,
            _name,
            _quantity,
            _pricePerUnit,
            ProduceStatus.Planted,
            msg.sender
        );
        produces[produceCount] = newproduce;
        farmerProduceIds[msg.sender].push(produceCount);
        emit ProduceAdded(
            produceCount,
            _name,
            _quantity,
            _pricePerUnit,
            msg.sender
        );
    }

    function updateProduce(
        uint256 _produceId,
        uint256 _quantity,
        uint256 _pricePerUnit
    ) external onlyProduceOwner(_produceId) {
        require(_quantity > 0, "You Entered an Invalid Value!");
        require(
            _pricePerUnit > 0,
            " The price per unit must be grrater than zero"
        );
        produces[_produceId].quantity = _quantity;
        produces[_produceId].pricePerUint = _pricePerUnit;
        emit ProduceUpdated(_produceId, _quantity, _pricePerUnit);
    }

    function updateProduceStatus(uint256 _produceId, ProduceStatus _status)
        external
        onlyOwner
    {
        require(_produceId > 0, "You entered an invalid produce id");
        produces[_produceId].status = _status;
        emit ProduceStatusUpdated(_produceId, _status);
    }

    function addShipment(
        uint256 _produceId,
        uint256 _quantity,
        string memory _destination
    ) external onlyProduceOwner(_produceId) {
        require(
            _quantity > 0,
            "Quantity must not be less than or equal to zero!"
        );

        require(
            produces[_produceId].status == ProduceStatus.Packed,
            "You cannot add the shiment is it is not in the packed stage!"
        );

        shipmentCount++;
        Shipment memory newShipment = Shipment(
            shipmentCount,
            _produceId,
            _quantity,
            _destination,
            false
        );

        shipments[shipmentCount] = newShipment;
        emit ShipmentAdded(
            shipmentCount,
            _produceId,
            _quantity,
            _destination,
            false
        );
    }

    function updateShipmentStatus(uint256 _shipmentId, bool _isShipped)
        external
        onlyOwner
    {
        require(_shipmentId > 0, " You entered an invalid shipment id!");

        shipments[_shipmentId].isShipped = _isShipped;
    }

    function getFarmerbyId(uint256 _id)
        external
        view
        returns (
            uint256 id,
            string memory name,
            address walletAdress
        )
    {
        require(_id > 0, "Yopu entered an invalid id!");
        Farmer memory farmer = farmers[farmerIds[_id]];
        return (farmer.id, farmer.name, farmer.walletAddress);
    }

    function getProduceById(uint256 _id)
        external
        view
        returns (
            uint256 id,
            string memory name,
            uint256 quantity,
            uint256 priePerUnit,
            ProduceStatus status,
            address owner
        )
    {
        require(_id > 0, "Invalid id has been entered!");
        Produce memory produce = produces[_id];
        return (
            produce.id,
            produce.name,
            produce.quantity,
            produce.pricePerUint,
            produce.status,
            produce.owner
        );
    }

    function getShipmentById(uint256 _id)
        external
        view
        returns (
            uint256 id,
            uint256 productId,
            uint256 quantity,
            string memory destination,
            bool isShipped
        )
    {
        require(_id > 0, "Invalid shipment id has been given!");
        Shipment memory shipment = shipments[_id];
        return (
            shipment.id,
            shipment.productId,
            shipment.quantity,
            shipment.destination,
            shipment.isShipped
        );
    }

    function getFarmerPoduceId() external view returns (uint256[] memory) {
        // if you use this comment seciton then make sure to add the_id as the function parameter

        // address farmer = farmerIds[_id];
        // uint[] memory producesAll = farmerProduceIds[farmer];
        // return (producesAll);
        return farmerProduceIds[msg.sender];
    }
}
